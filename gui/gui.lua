local ACTMath = require("utils.math")
local ACTStorage = require("utils.storage")
local ACTBelts = require("utils.belts")
local ACTRecipe = require("scripts.recipes.recipe")

local ACTGui = {}

local function getFrameName(playerIndex)
	return "ACT2_frame_" .. playerIndex
end

local function getGuiRoot(player)
	ACTStorage.setsettings(player)
	local s = ACTStorage.getSettings(player.name)
	local loc = s["gui-location"]
	if loc == "top" or loc == "left" then
		return player.gui[loc]
	end
	return player.gui.screen
end

local function findFrame(player)
	if not player or not player.valid then return nil end
	local frameName = getFrameName(player.index)
	local screen = player.gui.screen
	if screen and screen[frameName] and screen[frameName].valid then
		return screen[frameName]
	end
	local roots = { "top", "left" }
	for _, rootName in ipairs(roots) do
		local root = player.gui[rootName]
		if root and root[frameName] and root[frameName].valid then
			return root[frameName]
		end
	end
	return nil
end

ACTGui.findFrame = findFrame

function ACTGui.destroyFrame(player)
	if not player or not player.valid then return end
	local frameName = getFrameName(player.index)
	local roots = { "screen", "top", "left", "center", "goal" }
	for _, rootName in ipairs(roots) do
		local root = player.gui[rootName]
		if root and root[frameName] and root[frameName].valid then
			root[frameName].destroy()
		end
	end
end

local function spriteCheck(player, spritePath)
	if spritePath then
		if helpers.is_valid_sprite_path("item/" .. spritePath) then
			return "item/" .. spritePath
		elseif helpers.is_valid_sprite_path("entity/" .. spritePath) then
			return "entity/" .. spritePath
		elseif helpers.is_valid_sprite_path("technology/" .. spritePath) then
			return "technology/" .. spritePath
		elseif helpers.is_valid_sprite_path("recipe/" .. spritePath) then
			return "recipe/" .. spritePath
		elseif helpers.is_valid_sprite_path("fluid/" .. spritePath) then
			return "fluid/" .. spritePath
		elseif helpers.is_valid_sprite_path("utility/" .. spritePath) then
			return "utility/" .. spritePath
		end
	end
	return "utility/questionmark"
end

local function addNextInfoWrap(parent_section, i)
	local player = game.players[parent_section.player_index]
	if not player or not player.valid then return end

	local wrap = parent_section.add {
		type = "flow",
		name = "infoWrap" .. i,
		direction = "vertical",
		visible = false
	}
	local itemIPSWrap = wrap.add {
		type = "flow",
		name = "itemIPSWrap",
		direction = "horizontal",
		visible = false
	}
	itemIPSWrap.style.vertical_align = "center"
	itemIPSWrap.add {
		type = "sprite-button",
		name = "item_sprite",
		tooltip = "",
		visible = false,
		style = "ACT2_item_slot"
	}
	itemIPSWrap.add {
		type = "label",
		name = "IPSLabel",
		tooltip = "",
		caption = "",
		visible = false
	}
	itemIPSWrap.add {
		type = "label",
		name = "qualityIPSLabel",
		tooltip = "",
		caption = "",
		visible = false
	}
	wrap.add {
		type = "progressbar",
		name = "item_Bar",
		tooltip = "",
		visible = false
	}
end

local function guiDescendFind(currentGuiSection, tooltip, message, spritePath)
	if not currentGuiSection or not currentGuiSection.valid then return end
	for _, v in pairs(currentGuiSection.children) do
		if v.valid then
			if v.children and #v.children > 0 then
				guiDescendFind(v, tooltip, message, spritePath)
			elseif v.name == "recipeSprite" then
				v.tooltip = tooltip
				v.sprite = spritePath
			elseif v.name == "recipeCraftTime" then
				v.caption = message
			end
		end
	end
end

-- Iterates through the object's parents.
local function guiVisibleAttrParent(currentGuiSection, bool)
	local el = currentGuiSection
	while el and el.valid do
		if el.visible == bool then break end
		el.visible = bool
		el = el.parent
	end
end

-- Iterates through the object's children.
local function guiVisibleAttrChild(currentGuiSection, bool, p_index, storage_root)
	if not (currentGuiSection and currentGuiSection.valid) then return end

	-- Never hide title_bar when resetting children visibility
	if currentGuiSection.name == "title_bar" and not bool then
		return
	end

	p_index = p_index or currentGuiSection.player_index
	local player = game.players[p_index]
	local playerName = player and player.valid and player.name
	local s = ACTStorage.getSettings(playerName)
	storage_root = storage_root or s["gui-location"]
	local frame_name = getFrameName(p_index)

	local parent = currentGuiSection.parent
	if parent and parent.valid and parent.visible ~= bool then
		local p_name = parent.name
		if p_name ~= storage_root and p_name ~= frame_name then
			guiVisibleAttrParent(parent, bool)
		end
	end

	currentGuiSection.visible = bool

	local children = currentGuiSection.children
	if children and #children > 0 then
		for i = 1, #children do
			guiVisibleAttrChild(children[i], bool, p_index, storage_root)
		end
	end
end

local function desiredGuiTypeEntity(event)
	return event.gui_type == defines.gui_type.entity
end

local function desiredGuiNameSlider(event)
	if event.element and event.element.valid and event.element.name == event.player_index .. "_slider" then
		return true
	end
	return false
end

local function setupGui(player)
	local existing = findFrame(player)
	if existing then return existing end

	ACTStorage.setsettings(player)
	local root = getGuiRoot(player)
	local isScreen = (root == player.gui.screen)
	local frameName = getFrameName(player.index)

	local main_frame = root.add {
		type = "frame",
		name = frameName,
		direction = "vertical",
		visible = true,
	}

	main_frame.style.use_header_filler = true

	if isScreen then
		-- Restore saved position or default to near top-left
		local savedLocation = ACTStorage.getWindowLocation(player.name)
		if savedLocation and savedLocation.x and savedLocation.y then
			main_frame.location = savedLocation
		else
			main_frame.location = { x = 20, y = 80 }
		end
	end

	local title_flow = main_frame.add {
		type = "flow",
		direction = "horizontal",
		name = "title_bar",
	}
	if isScreen then
		title_flow.drag_target = main_frame
	end
	title_flow.style.horizontally_stretchable = true
	title_flow.style.horizontal_spacing = 8
	title_flow.style.bottom_padding = 4

	local title_label = title_flow.add {
		type = "label",
		name = "title_label",
		caption = "Actual Craft Time 2.0",
		style = "frame_title",
		ignored_by_interaction = true
	}
	if isScreen then
		title_label.drag_target = main_frame
	end

	local title_pusher = title_flow.add {
		type = "empty-widget",
		name = "title_pusher",
		style = isScreen and "draggable_space_header" or "empty_widget",
		ignored_by_interaction = true
	}
	title_pusher.style.height = 24
	title_pusher.style.horizontally_stretchable = true
	if isScreen then
		title_pusher.drag_target = main_frame
	end

	if script.active_mods["quality"] then
		local showQuality = ACTStorage.getQualityToggle(player.name)
		local qSprite = "utility/slot_icon_module"
		if helpers.is_valid_sprite_path("item/quality-module") then
			qSprite = "item/quality-module"
		end
		title_flow.add {
			type = "sprite-button",
			name = "ACT2_quality_toggle",
			style = "frame_action_button",
			sprite = qSprite,
			auto_toggle = true,
			toggled = showQuality,
			tooltip = showQuality and { "tooltips.ACT2_quality_toggle_on" } or { "tooltips.ACT2_quality_toggle_off" }
		}
	end

	local close_button = title_flow.add {
		type = "sprite-button",
		name = "ACT2_close_button",
		style = "frame_action_button",
		sprite = "utility/close",
		tooltip = { "gui.close" }
	}

	-- Assembler group
	local assembler_group = main_frame.add {
		type = "flow",
		name = "assemblerGroup",
		direction = "horizontal",
		visible = false
	}

	-- Recipe & Radio section
	assembler_group.add {
		type = "flow",
		name = "recipeRadioWrap",
		direction = "vertical",
		visible = false
	}

	local recipe_section = assembler_group.recipeRadioWrap.add {
		type = "flow",
		name = "recipeSection",
		direction = "vertical",
		visible = false
	}

	recipe_section.add {
		type = "label",
		name = "recipeLabel",
		caption = "Recipe",
		visible = false
	}
	recipe_section.add {
		type = "flow",
		name = "recipe",
		direction = "horizontal",
		visible = false
	}
	recipe_section.recipe.add {
		type = "sprite-button",
		name = "recipeSprite",
		tooltip = "",
		sprite = "",
		visible = false,
		style = "ACT2_recipe_slot"
	}
	local recipeInfo = recipe_section.recipe.add {
		type = "flow",
		name = "recipeInfo",
		direction = "vertical",
		visible = false
	}
	recipeInfo.add {
		type = "label",
		name = "recipeCraftTime",
		caption = "craft time",
		visible = false
	}
	recipeInfo.add {
		type = "label",
		name = "qualityChanceLabel",
		caption = "",
		visible = false
	}

	-- Radio buttons
	assembler_group.recipeRadioWrap.add {
		type = "flow",
		name = "radioSection",
		direction = "horizontal",
		visible = false
	}

	local radio_section = assembler_group.recipeRadioWrap.radioSection

	radio_section.add {
		type = "flow",
		name = "radioLables",
		direction = "vertical",
		visible = false
	}

	radio_section.add {
		type = "flow",
		name = "radioButtons",
		direction = "vertical",
		visible = false,
		style = "ACT2_vertical_flow"
	}

	radio_section.radioLables.add {
		type = "label",
		name = "labelTimeSecond",
		caption = "Seconds",
		tooltip = { 'controls.ACT2_IPS_IPM_T', 'seconds' },
		visible = false
	}
	radio_section.radioButtons.add {
		type = "radiobutton",
		name = "ACTTimeSecond",
		tooltip = { 'controls.ACT2_IPS_IPM_T', 'seconds' },
		state = true,
		visible = false
	}

	radio_section.radioLables.add {
		type = "label",
		name = "labelTimeMinute",
		caption = "Minutes",
		tooltip = { 'controls.ACT2_IPS_IPM_T', 'minutes' },
		visible = false
	}
	radio_section.radioButtons.add {
		type = "radiobutton",
		name = "ACTTimeMinute",
		tooltip = { 'controls.ACT2_IPS_IPM_T', 'minutes' },
		state = false,
		visible = false
	}

	-- Ingredients section
	assembler_group.add {
		type = "flow",
		name = "ingredientsSection",
		direction = "vertical",
		visible = false
	}
	assembler_group.ingredientsSection.add {
		type = "label",
		name = "sectionLabel",
		caption = "Ingredients",
		visible = false
	}

	-- Products section
	assembler_group.add {
		type = "flow",
		name = "productsSection",
		direction = "vertical",
		visible = false
	}
	assembler_group.productsSection.add {
		type = "label",
		name = "sectionLabel",
		caption = "Products",
		visible = false
	}

	-- Warning group
	local warning_group = main_frame.add {
		type = "flow",
		name = "warningGroup",
		direction = "vertical",
		visible = false
	}
	warning_group.add {
		type = "label",
		name = "warningLabel",
		caption = "",
		visible = false
	}

	-- Machine group
	local machine_group = main_frame.add {
		type = "flow",
		name = "machineGroup",
		direction = "vertical",
		visible = false
	}
	machine_group.add {
		type = "label",
		name = "machineLabel",
		caption = "Adjust number of machines",
		tooltip = { 'tooltips.scroll-wheel' },
		visible = false
	}
	machine_group.add {
		type = "flow",
		name = "sliderSection",
		direction = "horizontal",
		tooltip = { 'tooltips.scroll-wheel' },
		visible = false
	}

	local s = ACTStorage.getSettings(player.name)
	local maxSlider = s["max-slider-value"]

	machine_group.sliderSection.add {
		type = "sprite-button",
		name = "Sub5-ACT2-sliderButton",
		tooltip = { 'tooltips.add-sub', "-5", "1", "-31", "-25" },
		sprite = spriteCheck(player, "editor_speed_down"),
		style = "ACT2_buttons",
		visible = false
	}
	machine_group.sliderSection.add {
		type = "sprite-button",
		name = "Sub1-ACT2-sliderButton",
		tooltip = { 'tooltips.add-sub', "-1", { '', { 'tooltips.dn' }, ' ', maxSlider / 2 }, "-7", "-10" },
		sprite = spriteCheck(player, "left_arrow"),
		style = "ACT2_buttons",
		visible = false
	}
	machine_group.sliderSection.add {
		type = "slider",
		name = player.index .. "_slider",
		minimum_value = 1,
		maximum_value = maxSlider,
		tooltip = { 'tooltips.scroll-wheel' },
		style = "slider",
		visible = false
	}
	machine_group.sliderSection.add {
		type = "sprite-button",
		name = "Add1-ACT2-sliderButton",
		tooltip = { 'tooltips.add-sub', "+1", { '', { 'tooltips.up' }, ' ', maxSlider / 2 }, "+7", "+10" },
		sprite = spriteCheck(player, "right_arrow"),
		style = "ACT2_buttons",
		visible = false
	}
	machine_group.sliderSection.add {
		type = "sprite-button",
		name = "Add5-ACT2-sliderButton",
		tooltip = { 'tooltips.add-sub', "+5", maxSlider, "+31", "+25" },
		sprite = spriteCheck(player, "editor_speed_up"),
		style = "ACT2_buttons",
		visible = false
	}
	machine_group.sliderSection.add {
		type = "label",
		name = "sliderLabel",
		caption = "",
		visible = false
	}

	return main_frame
end

ACTGui.setupGui = setupGui

local function updateRadio(currentGuiSection)
	guiVisibleAttrChild(currentGuiSection, true)
end

local function updateRecipe(currentGuiSection, tooltip, message, spritePath, qualityBonus, showQuality)
	guiVisibleAttrChild(currentGuiSection, true)
	guiDescendFind(currentGuiSection, tooltip, message, spritePath)

	local qLabel = nil
	if currentGuiSection.recipe and currentGuiSection.recipe.recipeInfo and currentGuiSection.recipe.recipeInfo.qualityChanceLabel then
		qLabel = currentGuiSection.recipe.recipeInfo.qualityChanceLabel
	end

	if qLabel and qLabel.valid then
		if qualityBonus and qualityBonus > 0 and showQuality then
			local qPct = ACTMath.truncateNumber(qualityBonus * 100, 1)
			qLabel.caption = { '', "[color=160,225,120]★ Quality: +", tostring(qPct), "%[/color]" }
			local breakdownStr = "Quality module bonus: +" .. tostring(qPct) .. "%\n" ..
				"Chance to upgrade product tier:\n" ..
				"  • Uncommon: ~" .. tostring(ACTMath.truncateNumber(qualityBonus * 90, 2)) .. "%\n" ..
				"  • Rare: ~" .. tostring(ACTMath.truncateNumber(qualityBonus * 9, 2)) .. "%\n" ..
				"  • Epic: ~" .. tostring(ACTMath.truncateNumber(qualityBonus * 0.9, 3)) .. "%\n" ..
				"  • Legendary: ~" .. tostring(ACTMath.truncateNumber(qualityBonus * 0.1, 4)) .. "%"
			qLabel.tooltip = breakdownStr
			qLabel.visible = true
		else
			qLabel.visible = false
		end
	end
end

local function formatHourlyRate(ratePerSec)
	local rph = ratePerSec * 3600
	if rph >= 10000 then
		return "~" .. tostring(ACTMath.truncateNumber(rph / 1000, 1)) .. "k / 1h"
	elseif rph >= 10 then
		return "~" .. tostring(math.floor(rph + 0.5)) .. " / 1h"
	elseif rph >= 1 then
		local val = ACTMath.truncateNumber(rph, 1)
		if val == math.floor(val) then
			return "~" .. tostring(math.floor(val)) .. " / 1h"
		end
		return "~" .. tostring(val) .. " / 1h"
	elseif rph >= 0.01 then
		return "~" .. tostring(ACTMath.truncateNumber(rph, 2)) .. " / 1h"
	elseif rph > 0 then
		return "~" .. tostring(ACTMath.truncateNumber(rph, 3)) .. " / 1h"
	else
		return "0 / 1h"
	end
end

local function updateItem(recipe, items, current_section, minOrSec)
	local player = current_section.gui.player
	if not player or not player.valid then return end
	if not items then return end

	local showQuality = ACTStorage.getQualityToggle(player.name)

	for k, v in pairs(items) do
		if not current_section["infoWrap" .. k] then
			addNextInfoWrap(current_section, k)
		end
		current_section.visible = true
		current_section.sectionLabel.visible = true
		local guiElementInfoWrap_K = current_section["infoWrap" .. k]

		guiElementInfoWrap_K.visible = true
		guiElementInfoWrap_K.itemIPSWrap.visible = true
		guiElementInfoWrap_K.itemIPSWrap.item_sprite.visible = true
		guiElementInfoWrap_K.itemIPSWrap.item_sprite.sprite = spriteCheck(player, v.name)
		guiElementInfoWrap_K.itemIPSWrap.item_sprite.tooltip = v.localised_name or v.name

		local sliderVal = 1
		if storage.ACT2_slider and storage.ACT2_slider[player.name] and storage.ACT2_slider[player.name][recipe.name] then
			sliderVal = storage.ACT2_slider[player.name][recipe.name].value or 1
		end

		local totalRate = v.ips * sliderVal * minOrSec.value
		guiElementInfoWrap_K.itemIPSWrap.IPSLabel.caption = { '',
			ACTMath.truncateNumber(totalRate, 2),
			minOrSec.time
		}

		local hasQuality = v.quality_chance and v.quality_chance > 0 and showQuality
		local qLabel = guiElementInfoWrap_K.itemIPSWrap.qualityIPSLabel
		if hasQuality then
			local upgradedRate = totalRate * v.quality_chance
			local baseRate = totalRate * (1 - v.quality_chance)
			local qPercent = tostring(ACTMath.truncateNumber(v.quality_chance * 100, 1)) .. "%"
			local timeSuffix = (minOrSec.value == 1) and "/sec" or "/min"

			-- Base rate in items per second for hourly projections
			local basePerSec = (v.ips * sliderVal) * v.quality_chance

			if qLabel and qLabel.valid then
				qLabel.visible = true
				qLabel.caption = { '',
					" [color=160,225,120](★ ",
					ACTMath.truncateNumber(upgradedRate, 2),
					minOrSec.time,
					")[/color]"
				}
			end

			local tipText = "\nTotal: " .. tostring(ACTMath.truncateNumber(totalRate, 2)) .. timeSuffix .. "\n" ..
				"Quality upgrade chance: +" .. qPercent .. "\n" ..
				"  Base quality: " .. tostring(ACTMath.truncateNumber(baseRate, 2)) .. timeSuffix .. " (" .. tostring(ACTMath.truncateNumber((1 - v.quality_chance) * 100, 1)) .. "%)\n" ..
				"  Upgraded (★): " .. tostring(ACTMath.truncateNumber(upgradedRate, 2)) .. timeSuffix .. " (" .. qPercent .. ")\n" ..
				"    • Uncommon: ~" .. tostring(ACTMath.truncateNumber(upgradedRate * 0.9, 2)) .. timeSuffix .. " (" .. formatHourlyRate(basePerSec * 0.90) .. ")\n" ..
				"    • Rare: ~" .. tostring(ACTMath.truncateNumber(upgradedRate * 0.09, 2)) .. timeSuffix .. " (" .. formatHourlyRate(basePerSec * 0.09) .. ")\n" ..
				"    • Epic: ~" .. tostring(ACTMath.truncateNumber(upgradedRate * 0.009, 2)) .. timeSuffix .. " (" .. formatHourlyRate(basePerSec * 0.009) .. ")\n" ..
				"    • Legendary: ~" .. tostring(ACTMath.truncateNumber(upgradedRate * 0.001, 2)) .. timeSuffix .. " (" .. formatHourlyRate(basePerSec * 0.001) .. ")"

			if v.probability and v.probability < 1 then
				tipText = tipText .. "\nRecycling return: " .. tostring(v.probability * 100) .. "%"
			end

			local fullTip = { "", v.localised_name or v.name, tipText }
			guiElementInfoWrap_K.itemIPSWrap.IPSLabel.tooltip = fullTip
			if qLabel and qLabel.valid then
				qLabel.tooltip = fullTip
			end
		else
			if qLabel and qLabel.valid then
				qLabel.visible = false
			end
			if v.probability and v.probability < 1 then
				guiElementInfoWrap_K.itemIPSWrap.IPSLabel.tooltip = (v.probability * 100) .. "%"
			else
				guiElementInfoWrap_K.itemIPSWrap.IPSLabel.tooltip = ""
			end
		end

		if v.type ~= "fluid" and v.pbar then
			guiElementInfoWrap_K.item_Bar.visible = true
			guiElementInfoWrap_K.item_Bar.tooltip = v.pbar.tool
			guiElementInfoWrap_K.item_Bar.style.color = v.pbar.color
			guiElementInfoWrap_K.item_Bar.value = v.pbar.value
		end
		guiElementInfoWrap_K.itemIPSWrap.IPSLabel.visible = true
	end
end

local function updateWarning(currentGuiSection, message)
	guiVisibleAttrChild(currentGuiSection, true)
	currentGuiSection.warningLabel.caption = message
end

local function updateMachine(currentGuiSection, sliderValue, entity)
	guiVisibleAttrChild(currentGuiSection, true)
	currentGuiSection.sliderSection.sliderLabel.caption = { '', sliderValue, " ", entity.localised_name }
	local slider = currentGuiSection.sliderSection[currentGuiSection.player_index .. "_slider"]
	if slider and slider.valid then
		slider.slider_value = sliderValue
	end
end

local function toggleRadio(element)
	if not element or not element.valid or not element.parent then return end
	for k, v in pairs(element.parent.children_names) do
		local child = element.parent.children[k]
		if child and child.valid and child.type == "radiobutton" then
			if v ~= element.name then
				child.state = not child.state
			end
		end
	end
end

local function run(event)
	if not desiredGuiTypeEntity(event) then return end

	local entity = event.entity
	if not ACTRecipe.desiredEntity(entity) then return end

	local playerIndex = event.player_index
	local player = game.get_player(playerIndex)
	if not player or not player.valid then return end

	ACTStorage.setsettings(player)

	local frame = findFrame(player)
	if not frame then
		frame = setupGui(player)
	end
	if not frame or not frame.valid then return end

	-- Ensure window position is restored if on screen
	local isScreen = (frame.parent == player.gui.screen)
	if isScreen and not frame.location then
		frame.location = ACTStorage.getWindowLocation(player.name)
	end

	-- Reset frame visibility to prepare for update
	guiVisibleAttrChild(frame, false)
	frame.visible = true

	-- Ensure title bar and its controls are always visible
	if frame.title_bar and frame.title_bar.valid then
		frame.title_bar.visible = true
		for _, child in pairs(frame.title_bar.children) do
			if child.valid then
				child.visible = true
			end
		end
		if frame.title_bar.ACT2_quality_toggle and frame.title_bar.ACT2_quality_toggle.valid then
			local showQuality = ACTStorage.getQualityToggle(player.name)
			frame.title_bar.ACT2_quality_toggle.toggled = showQuality
			frame.title_bar.ACT2_quality_toggle.tooltip = showQuality and { "tooltips.ACT2_quality_toggle_on" } or { "tooltips.ACT2_quality_toggle_off" }
		end
	end

	local recipe = ACTRecipe.getRecipe(entity, player.name)
	local assembler_group = frame.assemblerGroup
	if not assembler_group then return end

	if not recipe then
		assembler_group.visible = true
		assembler_group.recipeRadioWrap.visible = true
		updateRecipe(assembler_group.recipeRadioWrap.recipeSection,
			{ 'tooltips.reset', entity.localised_name },
			{ 'captions.no-recipe' },
			spriteCheck(player, entity.name),
			0,
			false)
		return
	end

	ACTStorage.globalSliderStorage(player.name, recipe.name)

	local radioSecond = assembler_group.recipeRadioWrap.radioSection.radioButtons.ACTTimeSecond
	local minOrSec = ACTMath.determineMinOrSec(radioSecond)

	local qualityBonus = (recipe.effects and recipe.effects.quality and recipe.effects.quality.bonus) or 0
	local showQuality = ACTStorage.getQualityToggle(player.name)

	updateRecipe(assembler_group.recipeRadioWrap.recipeSection,
		{ 'tooltips.reset', recipe.localised_name },
		{ minOrSec.captions, ACTMath.truncateNumber(math.max(recipe.seconds, 1 / 60) / minOrSec.value,
			ACTMath.conditionalDecimalIncrease(recipe.seconds, 2)) },
		spriteCheck(player, recipe.name),
		qualityBonus,
		showQuality)

	updateRadio(assembler_group.recipeRadioWrap.radioSection)

	updateItem(recipe, recipe.ingredients, assembler_group.ingredientsSection, minOrSec)

	updateItem(recipe, recipe.products, assembler_group.productsSection, minOrSec)

	local warning_group = frame.warningGroup
	if recipe.is_capped and warning_group then
		updateWarning(warning_group, { 'captions.is-capped' })
	end

	local machine_group = frame.machineGroup
	if machine_group then
		local sliderVal = storage.ACT2_slider[player.name][recipe.name].value or 1
		updateMachine(machine_group, ACTMath.truncateNumber(sliderVal, 0), entity)
	end
end

ACTGui.run = run

local function resetACT(event)
	local player = game.players[event.player_index]
	if not player or not player.valid then return end
	event.entity = player.opened
	event.gui_type = defines.gui_type.entity
	run(event)
end

local function changeGuiSliderButtons(event)
	local shi = event.shift
	local alt = event.alt
	local con = event.control

	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player or not player.valid then return end
	local entity = player.opened
	if not entity or not entity.valid then return end

	local recipe = ACTRecipe.getRecipe(entity, player.name)
	if not recipe then return end

	ACTStorage.globalSliderStorage(player.name, recipe.name)
	local currentSlider = storage.ACT2_slider[player.name][recipe.name]
	local maxSlider = ACTStorage.getSettings(player.name)["max-slider-value"]
	local elementName = event.element.name

	if shi and not alt and not con then
		if elementName:find("Sub5") then
			currentSlider.value = currentSlider.value - 25
		elseif elementName:find("Sub1") then
			currentSlider.value = currentSlider.value - 10
		elseif elementName:find("Add1") then
			currentSlider.value = currentSlider.value + 10
		elseif elementName:find("Add5") then
			currentSlider.value = currentSlider.value + 25
		end
	elseif shi and con and not alt then
		if elementName:find("Sub5") then
			currentSlider.value = currentSlider.value - 31
		elseif elementName:find("Sub1") then
			currentSlider.value = currentSlider.value - 7
		elseif elementName:find("Add1") then
			currentSlider.value = currentSlider.value + 7
		elseif elementName:find("Add5") then
			currentSlider.value = currentSlider.value + 31
		end
	elseif con and not shi and not alt then
		if elementName:find("Sub5") then
			currentSlider.value = 1
		elseif elementName:find("Sub1") then
			if currentSlider.value >= maxSlider / 2 then
				currentSlider.value = maxSlider / 2
			end
		elseif elementName:find("Add1") then
			if currentSlider.value <= maxSlider / 2 then
				currentSlider.value = maxSlider / 2
			end
		elseif elementName:find("Add5") then
			currentSlider.value = maxSlider
		end
	elseif not shi and not alt and not con then
		if elementName:find("Sub5") then
			currentSlider.value = currentSlider.value - 5
		elseif elementName:find("Sub1") then
			currentSlider.value = currentSlider.value - 1
		elseif elementName:find("Add1") then
			currentSlider.value = currentSlider.value + 1
		elseif elementName:find("Add5") then
			currentSlider.value = currentSlider.value + 5
		end
	end

	if currentSlider.value < 1 then
		currentSlider.value = 1
	elseif currentSlider.value > maxSlider then
		currentSlider.value = maxSlider
	end

	event.gui_type = defines.gui_type.entity
	event.entity = entity
	run(event)
end

local function playerSlid(event)
	if not desiredGuiNameSlider(event) then return end
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player or not player.valid then return end
	local entity = player.opened
	if not entity or not entity.valid then return end

	local recipe = ACTRecipe.getRecipe(entity, player.name)
	if not recipe then return end

	ACTStorage.globalSliderStorage(player.name, recipe.name)
	local currentSlider = storage.ACT2_slider[player.name][recipe.name]
	local sensitivity = ACTStorage.getSettings(player.name)["sensitivity-value"]

	if math.abs(currentSlider.value - event.element.slider_value) >= (sensitivity / 10) then
		currentSlider.value = event.element.slider_value
		event.entity = entity
		event.gui_type = defines.gui_type.entity
		run(event)
	end
end

local function closeGui(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player or not player.valid then return end

	local frame = findFrame(player)
	if frame and frame.valid then
		guiVisibleAttrChild(frame, false)
	end
end

local function playerClickedGui(event)
	if not event.element or not event.element.valid then return end
	local elementName = event.element.name

	if elementName == "ACT2_close_button" then
		closeGui(event)
		return
	end

	if elementName == "ACT2_quality_toggle" then
		local playerIndex = event.player_index
		local player = game.players[playerIndex]
		if not player or not player.valid then return end

		local currentVal = ACTStorage.getQualityToggle(player.name)
		local newVal = not currentVal
		ACTStorage.setQualityToggle(player.name, newVal)

		if event.element and event.element.valid then
			event.element.toggled = newVal
			event.element.tooltip = newVal and { "tooltips.ACT2_quality_toggle_on" } or { "tooltips.ACT2_quality_toggle_off" }
		end

		if player.opened and player.opened.valid and ACTRecipe.desiredEntity(player.opened) then
			local refreshEvent = {
				player_index = playerIndex,
				entity = player.opened,
				gui_type = defines.gui_type.entity
			}
			run(refreshEvent)
		end
		return
	end

	if event.element.type ~= "sprite-button" then return end

	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player or not player.valid then return end

	if elementName == "recipeSprite" then
		resetACT(event)
		return
	end
	if elementName:find("ACT2%-sliderButton") then
		changeGuiSliderButtons(event)
		return
	end
end

local function radiobutton(event)
	if not event.element or not event.element.valid then return end

	if event.input_name == "ACT2_IPS_IPM" then
		for _, v in pairs(event.element.children_names) do
			local child = event.element[v]
			if child and child.valid and child.state == true then
				child.state = not child.state
				event.element = child
				break
			end
		end
	end

	if event.element.name and event.element.name:find("ACTTime") then
		toggleRadio(event.element)
		local playerIndex = event.player_index
		local player = game.players[playerIndex]
		if not player or not player.valid then return end

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity
		run(event)
	end
end

local function customInputForRadioButton(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player or not player.valid then return end

	local frame = findFrame(player)
	if not frame or not frame.valid then
		frame = setupGui(player)
	end

	if frame and frame.assemblerGroup and frame.assemblerGroup.recipeRadioWrap and
		frame.assemblerGroup.recipeRadioWrap.radioSection and
		frame.assemblerGroup.recipeRadioWrap.radioSection.radioButtons then
		event.element = frame.assemblerGroup.recipeRadioWrap.radioSection.radioButtons
		radiobutton(event)
	end
end

local function onGuiLocationChanged(event)
	if not event.element or not event.element.valid then return end
	if event.element.name == getFrameName(event.player_index) then
		local player = game.get_player(event.player_index)
		if player and player.valid and event.element.location then
			ACTStorage.setWindowLocation(player.name, event.element.location)
		end
	end
end

-- Export event handlers
ACTGui.onGuiOpened = run
ACTGui.onGuiClosed = closeGui
ACTGui.onGuiClick = playerClickedGui
ACTGui.onGuiValueChanged = playerSlid
ACTGui.onGuiCheckedStateChanged = radiobutton
ACTGui.onCustomInput = customInputForRadioButton
ACTGui.onGuiLocationChanged = onGuiLocationChanged

return ACTGui
