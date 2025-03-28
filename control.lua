local function truncateNumber(nu, digit)
	--game.print("number "..nu.." digit "..digit)
	local k = 1
	while nu > k do
		k = k * 10
		digit = digit + 1
	end
	--game.print("k "..k..", digit "..digit)
	nu = string.format("%." .. digit .. "f", nu / k) * k
	return nu
end

local function conditionalDecimalIncrease(input, x)
	if input < .25 and not (input < .025) then return x + 1 end
	if input < .025 then return x + 2 end
	return x
end

local function amountFromPumpjack(entity)
	if entity.name:find("pumpjack") then
		return (entity.mining_target.amount / 30000)
	end
	return nil
end

local function amountMaxMinAverage(product)
	if not product.amount_max or not product.amount_min then return nil end
	return (product.amount_max + product.amount_min) / 2
end

local function getLocalisedName(name)
	if prototypes.recipe[name] then
		return prototypes.recipe[name].localised_name
	end
	if prototypes.entity[name] then
		return prototypes.entity[name].localised_name
	end
	if prototypes.fluid[name] then
		return prototypes.fluid[name].localised_name
	end
	if prototypes.item[name] then
		return prototypes.item[name].localised_name
	end
	return name
end

local function globalSliderStorage(playerName, recipeName)
	if not storage.ACT2_slider then
		storage.ACT2_slider = {}
	end
	if not storage.ACT2_slider[playerName] then
		storage.ACT2_slider[playerName] = {}
	end
	if not storage.ACT2_slider[playerName][recipeName] then
		storage.ACT2_slider[playerName][recipeName] = { value = 1 }
	end
end
local function findPrototypeData(playerName)
	if not bltsInts then
		bltsInts = {}
	end
	if not bltsInts[playerName] then
		bltsInts[playerName] = { source = {} }
	end
	for k, v in pairs(prototypes.entity) do
		if k:find("transport%-belt") and not k:find("ground") and v.belt_speed then
			bltsInts[playerName].source[k] = ((60 * v.belt_speed) / (1 / 8)) -- I don't remember why it needs 8/64(1/8) but it does: 8 items per tile?
		end
	end
end
local function pbarTraits(IPS, playerName)
	IPS = tonumber(IPS)
	local belt = ""
	local color = {}
	local value = 0
	local tool = {}
	-- may contain mod belts, bob's/better etc.
	if not bltsInts then
		findPrototypeData(playerName)
	end
	
	
	if bltsInts[playerName].source["basic-transport-belt"] and  --Bobs - 7.5
		IPS <= bltsInts[playerName].source["basic-transport-belt"] then
		belt = "basic-transport-belt"
		color = { r = 0.15, g = 0.15, b = 0.15 } --38, 38, 38
		value = IPS / bltsInts[playerName].source["basic-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["basic-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif IPS <= bltsInts[playerName].source["transport-belt"] then --vanilla - 15
		belt = "transport-belt"
		color = { r = 0.98, g = 0.73, b = 0.0 }                   -- 250, 186, 0
		value = IPS / bltsInts[playerName].source["transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif IPS <= bltsInts[playerName].source["fast-transport-belt"] then --vanilla - 30
		belt = "fast-transport-belt"
		color = { r = 0.98, g = 0.27, b = 0.06 }                       -- 250, 69, 15
		value = IPS / bltsInts[playerName].source["fast-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["fast-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif IPS <= bltsInts[playerName].source["express-transport-belt"] then --vanilla - 45
		belt = "express-transport-belt"
		color = { r = 0.15, g = 0.67, b = 0.71 }                          -- 38, 171, 181
		value = IPS / bltsInts[playerName].source["express-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["express-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["turbo-transport-belt"] and --Bobs - 60
	IPS <= bltsInts[playerName].source["turbo-transport-belt"] then
	belt = "turbo-transport-belt"
	color = { r = 0.35, g = 0.76, b = 0.16 } -- 90, 196, 42  green
	value = IPS / bltsInts[playerName].source["turbo-transport-belt"]
	tool = { "tooltips.percent-of",
	tostring(
		truncateNumber(IPS / bltsInts[playerName].source["turbo-transport-belt"] * 100, 2)),
			prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["5d-mk4-transport-belt"] and --5dim - 57.6
		IPS <= bltsInts[playerName].source["5d-mk4-transport-belt"] then
		belt = "5d-mk4-transport-belt"
		color = { r = 0.08, g = 0.66, b = 0.14 } -- 20, 168, 36
		value = IPS / bltsInts[playerName].source["5d-mk4-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["5d-mk4-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["kr-advanced-transport-belt"] and --Kr - 60
		IPS <= bltsInts[playerName].source["kr-advanced-transport-belt"] then
		belt = "kr-advanced-transport-belt"
		color = { r = 0.13, g = 0.92, b = 0.09 } -- 34, 235, 23  green
		value = IPS / bltsInts[playerName].source["kr-dvanced-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["kr-advanced-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["5d-mk5-transport-belt"] and --5dim - 72
		IPS <= bltsInts[playerName].source["5d-mk5-transport-belt"] then
		belt = "5d-mk5-transport-belt"
		color = { r = 0.89, g = 0.91, b = 0.96 } -- 227, 232, 245
		value = IPS / bltsInts[playerName].source["5d-mk5-transpor-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["5d-mk5-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["ultimate-transport-belt"] and --Bobs - 75
		IPS <= bltsInts[playerName].source["ultimate-transport-belt"] then
		belt = "ultimate-transport-belt"
		color = { r = 0.07, g = 1.0, b = 0.62 } -- 18, 255, 158 green
		value = IPS / bltsInts[playerName].source["ultimate-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["ultimate-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["kr-superior-transport-belt"] and --Kr- 90
		IPS <= bltsInts[playerName].source["kr-superior-transport-belt"] then
		belt = "kr-superior-transport-belt"
		color = { r = 0.82, g = 0.00, b = 0.97 } -- 210, 1, 247 purple--*********************
		value = IPS / bltsInts[playerName].source["kr-superior-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["kr-superior-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	elseif bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] and --Better Belts - 96
		IPS <= bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] then
		belt = "BetterBelts_ultra-transport-belt"
		color = { r = .22, g = .84, b = .11 } --56, 213, 27 green
		value = IPS / bltsInts[playerName].source["BetterBelts_ultra-transport-belt"]
		tool = { "tooltips.percent-of",
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["BetterBelts_ultra-transport-belt"] * 100, 2)),
				prototypes.item[belt].localised_name }
	else
		--game.print("ips is inf")
		belt = "express-transport-belt"
		color = { r = 1, g = 1, b = 1 }                                                                                                                      --white
		value = IPS / bltsInts[playerName].source["express-transport-belt"]
		tool = { '',
		tostring(
			truncateNumber(IPS / bltsInts[playerName].source["express-transport-belt"], 2)),
				" ",
				prototypes.item[belt].localised_name }                                                                                                     --plural will be a problem
	end
	return { belt = belt, color = color, value = value, tool = tool }
end

local function copyProductsForWriteControl(recipe)
	local products = {}
	for p, o in pairs(recipe.products) do
		products[p] = {}
		for l, k in pairs(o) do
			products[p][l] = k
		end
	end

	for _, recipeIngredient in pairs(recipe.ingredients) do
		for i, recipeProduct in pairs(products) do
			local productAmount = recipeProduct.amount or amountMaxMinAverage(recipeProduct) or 1
			local IngredientAmount = recipeIngredient.amount or amountMaxMinAverage(recipeIngredient) or 1
			if recipeProduct.name == recipeIngredient.name and productAmount >= IngredientAmount then --there should not be amount_max/amount_min **there is in mods
				if recipeProduct.amount then
					recipeProduct.amount = productAmount - IngredientAmount
				elseif recipeProduct.amount_max and recipeProduct.amount_min and recipeIngredient.amount_max and recipeIngredient.amount_min then
					recipeProduct.amount_max = recipeProduct.amount_max - recipeIngredient.amount_max
					recipeProduct.amount_min = recipeProduct.amount_min - recipeIngredient.amount_min
				end
			end
		end
	end
	return products
end

local function expandIngredients(ingredients, sec, playerName, recipeName, recipe_bonus)
	if not playerName then return {} end --hopefully this never happens
	local ingredientTable = {}
	if not recipe_bonus then recipe_bonus = 0 end
	for k, ingredient in pairs(ingredients) do
		local IPS = (ingredient.amount / math.max(sec, 1 / 60)) / (recipe_bonus + 1)  -- ingredient amount is also capped by tick
		ingredientTable[k] = ingredient
		ingredientTable[k].localised_name = getLocalisedName(ingredient.name)
		ingredientTable[k].ips = IPS
		ingredientTable[k].pbar = pbarTraits(IPS * storage.ACT2_slider[playerName][recipeName].value, playerName)
	end
	return ingredientTable
end

local function expandProducts(products, sec, playerName, effects, recipeName)
	if not playerName then return {} end --hopefully this never happens
	local productTable = {}
	
	local playerForce = game.players[playerName].force
	for k, product in pairs(products) do
		local amount = product.amount or amountMaxMinAverage(product) or 1
		local expectedAmount = (product.probability or 1) * amount
		local IPS_main = expectedAmount / math.max(sec, 1 / 60)                      -- recipes can be executed only once per tick
		local IPS_productivity = expectedAmount * effects.productivity.bonus / sec   -- productivity bonus does not have cap
		local IPS = IPS_main + IPS_productivity
		productTable[k] = product
		productTable[k].localised_name = getLocalisedName(product.name)
		productTable[k].ips = IPS
		productTable[k].pbar = pbarTraits(IPS * storage.ACT2_slider[playerName][recipeName].value, playerName)
	end
	if recipeName == "rocket-part" then
		local expectedAmount = 10  --if a mod changes how many space-science-pack's in the rocket-part recipe then this will be wrong - need to figure out how/where to pull it from game data
		local IPS_main = expectedAmount / math.max(sec, 1 / 60) -- recipes can be executed only once per tick
		local IPS_productivity = expectedAmount * effects.productivity.bonus / sec   -- productivity bonus does not have cap
		local IPS = IPS_main + IPS_productivity
		if (script.active_mods["space-age"]) then
			productTable = nil; -- no product in space age
		else
			productTable[#products + 1] = {
				amount = 10,
				name = "space-science-pack",
				type = "item",
				localised_name = getLocalisedName("space-science-pack"),
				ips = IPS,
				pbar = pbarTraits(IPS * storage.ACT2_slider[playerName][recipeName].value, playerName)
			}
		end
	end
	return productTable
end

local function expandProductsMines(products, sec, playerName, effects, recipeName, entity)
	if not playerName then
		return {} --hopefully this never happens
	end
	local productTable = {}
	local playerForce = game.players[playerName].force
	for k, product in pairs(products) do
		local amount = amountFromPumpjack(entity) or product.amount or amountMaxMinAverage(product) or
		1                                                                                          --entity.mining_target.amount
		local expectedAmount = (product.probability or 1) * amount
		local IPS_main = expectedAmount / math.max(sec, 1 / 60)
		local IPS_productivity = expectedAmount *
		(playerForce.mining_drill_productivity_bonus + effects.productivity.bonus) / sec
		local IPS = IPS_main + IPS_productivity
		productTable[k] = product
		productTable[k].localised_name = getLocalisedName(product.name)
		productTable[k].ips = IPS
		productTable[k].pbar = pbarTraits(IPS * storage.ACT2_slider[playerName][recipeName].value, playerName)
	end
	return productTable
end

local function getEffects(entity)
	local effects = {
		consumption = { bonus = 0.0 },
		speed = { bonus = 0.0 },
		productivity = { bonus = 0.0 },
		pollution = { bonus = 0.0 }
	}
	if entity.effects then
		if entity.effects.speed then
			effects.speed.bonus = entity.effects.speed
		end
		if entity.effects.productivity and entity.effects.productivity > 0 then
			effects.productivity.bonus = entity.effects.productivity
		end
	end
	return effects
end

local function getRecipeFromEntity(entity, playerName)
	if entity.type:find("assembling%-machine") or
		entity.type:find("rocket%-silo") then
		local recipe = entity.get_recipe()
		if recipe then
			local recipe_bonus = recipe.productivity_bonus
			local recipeProducts = copyProductsForWriteControl(recipe)
			globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / (entity.crafting_speed * (recipe_bonus + 1)) --x(y+1)
			local is_capped = false
			if sec < (1 / 60) then
				is_capped = true
			end

			return {
				name = recipe.name,
				localised_name = recipe.localised_name,
				ingredients = expandIngredients(recipe.ingredients, sec, playerName, recipe.name, recipe_bonus),
				products = expandProducts(recipeProducts, sec, playerName, effects, recipe.name),
				seconds = sec,
				effects = effects,
				is_capped = is_capped
			}
		end
	end
end

local function getRecipeFromFurnaceOutput(entity, playerName)
	if entity.type:find("furnace") then
		for item, _ in pairs(entity.get_output_inventory().get_contents()) do --can get several *oil*?
			local recipe = prototypes.recipe[item]
			if recipe then
				local recipe_bonus = recipe.productivity_bonus
				globalSliderStorage(playerName, recipe.name)
				local effects = getEffects(entity)
				local sec = recipe.name.energy / (entity.crafting_speed * (effects.speed.bonus + 1)) --x(y+1)
				local is_capped = false
				if sec < (1 / 60) then
					is_capped = true
				end
				return {
					name = recipe.name.name,
					localised_name = recipe.name.localised_name,
					ingredients = expandIngredients(recipe.name.ingredients, sec, playerName, recipe.name),
					products = expandProducts(recipe.name.products, sec, playerName, effects, recipe.name),
					seconds = sec,
					effects = effects,
					is_capped = is_capped
				}
			end
		end
	end
	return nil
end

local function getRecipeFromFurnace(entity, playerName)
	if entity.type:find("furnace") then
		if not entity.get_recipe() then return nil end
		local recipe = entity.get_recipe()
		if recipe then
			local recipe_bonus = recipe.productivity_bonus
			globalSliderStorage(playerName, recipe.name)
			local effects = getEffects(entity)
			local sec = recipe.energy / (entity.crafting_speed * (effects.speed.bonus + 1)) --x(y+1)
			local is_capped = false
			if sec < (1 / 60) then
				is_capped = true
			end
			return {
				name = recipe.name,
				localised_name = recipe.localised_name,
				ingredients = expandIngredients(recipe.ingredients, sec, playerName, recipe.name,recipe_bonus),
				products = expandProducts(recipe.products, sec, playerName, effects, recipe.name),
				seconds = sec,
				effects = effects,
				is_capped = is_capped
			}
		end
	else
		return nil
	end
end

local function getRecipeFromLab(entity, playerName)
	if entity.type:find("lab") then
		local research = entity.force.current_research
		if research then
			globalSliderStorage(playerName, research.name)
			local effects = getEffects(entity)
			local sec = (research.research_unit_energy / 60) / ((entity.force.laboratory_speed_modifier + 1) * (effects.speed.bonus + 1)) -- blind fix
			local is_capped = false
			if sec < (1 / 60) then
				is_capped = true
			end
			return {
				name = research.name,
				localised_name = research.localised_name,
				ingredients = expandIngredients(research.research_unit_ingredients, sec, playerName, research.name),
				seconds = sec,
				effects = effects,
				is_capped = is_capped
			}
		end
	end
end

local function getRecipeFromMiningTarget(entity, playerName)
	if entity.type:find("mining%-drill") then
		local miningTarget = entity.mining_target
		if miningTarget then
			globalSliderStorage(playerName, miningTarget.name)
			local effects = getEffects(entity)
			local sec = miningTarget.prototype.mineable_properties.mining_time /
			(entity.prototype.mining_speed * (effects.speed.bonus + 1))
			-- if sec == math.huge then
			-- game.print("sec = 0")
			-- sec = 0 -- this is not a good solution, but what is?
			-- end
			-- game.print("mining time "..miningTarget.prototype.mineable_properties.mining_time)
			-- game.print("/ (mining speed "..entity.prototype.mining_speed)
			-- game.print(" * speed.bonus "..effects.speed.bonus)
			local is_capped = false
			--Productivity bonus (both from module and research) for mining seems not being capped by tick. I don't know why. :(
			if sec < (1 / 60) then
				is_capped = true
			end
			local recipe = {
				name = miningTarget.name,
				localised_name = miningTarget.localised_name,
				products = expandProductsMines(miningTarget.prototype.mineable_properties.products, sec, playerName,
					effects, miningTarget.name, entity),
				seconds = sec,
				effects = effects,
				is_capped = is_capped
			}
			if miningTarget.prototype.mineable_properties.fluid_amount then
				recipe.ingredients = expandIngredients(
					{ {
						name = miningTarget.prototype.mineable_properties.required_fluid,
						amount = miningTarget.prototype.mineable_properties.fluid_amount / 10,
						type = "fluid"
					} },
					sec, playerName, miningTarget.name)
			end
			return recipe
		end
	end
end

local function getRecipe(entity, PlayerName)
	return getRecipeFromEntity(entity, PlayerName) or getRecipeFromFurnaceOutput(entity, PlayerName) or
	getRecipeFromFurnace(entity, PlayerName) or getRecipeFromLab(entity, PlayerName) or
	getRecipeFromMiningTarget(entity, PlayerName) or nil
end
-- player is not used
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
	if not player then return end
	parent_section.add { type = "flow" --[[X--]], name = "infoWrap" .. i, direction = "vertical", visible = false --[[*--]] }
	local parent_section_infoWrap = parent_section["infoWrap" .. i]
	parent_section_infoWrap.add { type = "flow" --[[X--]], name = "itemIPSWrap", visible = false --[[*--]] }
	parent_section_infoWrap.itemIPSWrap.add { type = "sprite-button", name = "item_sprite", tooltip = "", visible = false --[[*--]], style = ACT2_buttons }
	parent_section_infoWrap.itemIPSWrap.add { type = "label", name = "IPSLabel", tooltip = "", caption = "", visible = false --[[*--]] }
	parent_section_infoWrap.add { type = "progressbar", name = "item_Bar", tooltip = "", visible = false --[[*--]] }
end

local function guiDescendFind(currentGuiSection, tooltip, message, spritePath)
	for _, v in pairs(currentGuiSection.children) do
		if next(v.children) then
			guiDescendFind(v, tooltip, message, spritePath)
		elseif v.name == "recipeSprite" then
			v.tooltip = tooltip
			v.sprite = spritePath
		elseif v.name == "recipeCraftTime" then
			v.caption = message
		end
	end
end

local function guiVisibleAttrAscend(currentGuiSection, bool)
	--top level gui element or other ("top" or "left" (or "center"))
	if currentGuiSection == nil then return end
	--currentGuiSection is already true/false (assume parent is as well if a parent?)
	if currentGuiSection.visible == bool then return end

	currentGuiSection.visible = bool

	if not currentGuiSection.parent then return end
	guiVisibleAttrAscend(currentGuiSection.parent, bool)
end

local function guiVisibleAttrDescend(currentGuiSection, bool)
	--or not next(currentGuiSection)  deleted that because it works without it and dont know any fix
	if currentGuiSection == nil then return end --invalid or an enpty table
	local player = game.players[currentGuiSection.player_index]
	if not player then return end
	if currentGuiSection.parent and currentGuiSection.parent.visible ~= bool and not (currentGuiSection.parent.name == storage.ACT2[player.name]["gui-location"]) and currentGuiSection.parent.name ~= "ACT2_frame_" .. currentGuiSection.player_index then
		guiVisibleAttrAscend(currentGuiSection.parent, bool)
	end
	currentGuiSection.visible = bool

	for _, v in pairs(currentGuiSection.children) do
		guiVisibleAttrDescend(v, bool)
	end
end

local function setsettings(player)
	if not player then return end
	if not storage.ACT2 then
		storage.ACT2 = {}
	end
	if not storage.ACT2[player.name] then
		storage.ACT2[player.name] = {
			["gui-location"] = player.mod_settings["ACT2-Gui-Location"].value,
			["simple-text"] = player.mod_settings["ACT2-simple-text"].value,
			["max-slider-value"] = player.mod_settings["ACT2-max-slider-value"].value,
			["sensitivity-value"] = player.mod_settings["ACT2-slider-sensitivity"].value,
		}
	else --check for changes
		if storage.ACT2[player.name]["gui-location"] ~= player.mod_settings["ACT2-Gui-Location"].value then
			storage.ACT2[player.name]["gui-location"] = player.mod_settings["ACT2-Gui-Location"].value
		end
		if storage.ACT2[player.name]["simple-text"] ~= player.mod_settings["ACT2-simple-text"].value then
			storage.ACT2[player.name]["simple-text"] = player.mod_settings["ACT2-simple-text"].value
		end
		if storage.ACT2[player.name]["max-slider-value"] ~= player.mod_settings["ACT2-max-slider-value"].value then
			storage.ACT2[player.name]["max-slider-value"] = player.mod_settings["ACT2-max-slider-value"].value
		end
		if storage.ACT2[player.name]["sensitivity-value"] ~= player.mod_settings["ACT2-slider-sensitivity"].value then
			storage.ACT2[player.name]["sensitivity-value"] = player.mod_settings["ACT2-slider-sensitivity"].value
		end
	end
end

local function closeGui(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	setsettings(player)
	local guiLocation = storage.ACT2[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation]
	guiVisibleAttrDescend(playersGui["ACT2_frame_" .. playersGui.player_index], false)
end

local function updateRadio(currentGuiSection)
	guiVisibleAttrDescend(currentGuiSection, true)
end

local function updateRecipe(currentGuiSection, tooltip, message, spritePath)
	guiVisibleAttrDescend(currentGuiSection, true)
	guiDescendFind(currentGuiSection, tooltip, message, spritePath)
end

local function updateItem(recipe, items, current_section, minOrSec)
	local player = current_section.gui.player
	if not player then return end
	if not items then return end
	for k, v in pairs(items) do
		if not current_section["infoWrap" .. k] then
			addNextInfoWrap(current_section, k)
		end
		current_section.visible = true
		current_section.sectionLabel.visible = true
		local guiElementInfoWrap_K = current_section["infoWrap" .. k]

		guiElementInfoWrap_K.visible = true
		guiElementInfoWrap_K.visible = true
		guiElementInfoWrap_K.itemIPSWrap.visible = true
		guiElementInfoWrap_K.itemIPSWrap.item_sprite.visible = true
		guiElementInfoWrap_K.itemIPSWrap.item_sprite.sprite = spriteCheck(player, v.name) --additions/changes

		guiElementInfoWrap_K.itemIPSWrap.item_sprite.tooltip = v.localised_name or v.name
		guiElementInfoWrap_K.itemIPSWrap.IPSLabel.caption = { '', truncateNumber(
		v.ips * storage.ACT2_slider[player.name][recipe.name].value * minOrSec.value, 2), minOrSec.time }
		if v.probability and v.probability < 1 then
			guiElementInfoWrap_K.itemIPSWrap.IPSLabel.tooltip = v.probability * 100 .. "%"
		else
			guiElementInfoWrap_K.itemIPSWrap.IPSLabel.tooltip = ""
		end

		if v.type ~= "fluid" then
			guiElementInfoWrap_K.item_Bar.visible = true
			guiElementInfoWrap_K.item_Bar.tooltip = v.pbar.tool
			guiElementInfoWrap_K.item_Bar.style.color = v.pbar.color
			guiElementInfoWrap_K.item_Bar.value = v.pbar.value
		end
		guiElementInfoWrap_K.itemIPSWrap.IPSLabel.visible = true
	end
end

local function updateWarning(currentGuiSection, message)
	guiVisibleAttrDescend(currentGuiSection, true)
	currentGuiSection.warningLabel.caption = message
end

local function updateMachine(currentGuiSection, sliderValue, entity)
	guiVisibleAttrDescend(currentGuiSection, true)
	currentGuiSection.sliderSection.sliderLabel.caption = { '', sliderValue, " ", entity.localised_name }
	currentGuiSection.sliderSection[currentGuiSection.player_index .. "_slider"].slider_value = sliderValue
end

local function desiredGuiTypeEntity(event)
	if event.gui_type == defines.gui_type.entity then
		return true
	else
		return false
	end
end

local function desiredGuiNameSlider(event)
	if event.element.name == event.player_index .. "_slider" then
		return true
	else
		return false
	end
end

local function desiredEntity(entity)
	if entity and ( --add in reactor?
			entity.type:find("assembling%-machine") or
			entity.type:find("furnace") and not entity.name:find("reverse") or
			entity.type:find("rocket%-silo") or
			entity.type:find("lab") or
			entity.type:find("mining%-drill")) then
		return true
	else
		return false
	end
end

local function toggleRadio(element)
	for k, v in pairs(element.parent.children_names) do
		if element.parent.children[k].type ~= "radiobutton" then return end
		if v ~= element.name then
			element.parent.children[k].state = not element.parent.children[k].state
		end
	end
end

local function determineMinOrSec(ACT2_time_second)
	if ACT2_time_second.state then
		return { value = 1, time = { 'captions.perSec' }, captions = 'captions.seconds' }
	else
		return { value = 60, time = { 'captions.perMin' }, captions = 'captions.minutes' }
	end
end

local function setupGui(player, playersGui)
	-- outside container
	playersGui.add {gui = defines.relative_gui_type.controller_gui, position = defines.relative_gui_position.top, type = "frame", name = "ACT2_frame_" .. playersGui.player_index, direction = "vertical", visible = true }
	
	--add assemblerGroup
	playersGui["ACT2_frame_" .. playersGui.player_index].add { type = "flow" --[[X--]], name = "assemblerGroup", direction = "horizontal", visible = false --[[*--]] }
	local assembler_group = playersGui["ACT2_frame_" .. playersGui.player_index].assemblerGroup

	--"main" recipe section
	assembler_group.add { type = "flow" --[[X--]], name = "recipeRadioWrap", direction = "vertical", visible = false --[[*--]] }
	assembler_group.recipeRadioWrap.add { type = "flow" --[[X--]], name = "recipeSection", direction = "vertical", visible = false --[[*--]] }
	local recipe_section = assembler_group.recipeRadioWrap.recipeSection

	recipe_section.add { type = "label", name = "recipeLabel", caption = "Recipe", visible = false --[[*--]] }
	recipe_section.add { type = "flow" --[[X--]], name = "recipe", direction = "horizontal", visible = false --[[*--]] }
	recipe_section.recipe.add { type = "sprite-button", name = "recipeSprite", tooltip = "", sprite = "", visible = false --[[*--]] }
	recipe_section.recipe.add { type = "label", name = "recipeCraftTime", caption = 'craft time', visible = false --[[*--]] }

	-- if no recipe, all below is(should) not visible ***

	--add radio
	assembler_group.recipeRadioWrap.add { type = "flow", name = "radioSection", direction = "horizontal", visible = false }
	local radio_section = assembler_group.recipeRadioWrap.radioSection
	radio_section.add { type = "flow", name = "radioLables", direction = "vertical", visible = false }
	radio_section.add { type = "flow", name = "radioButtons", direction = "vertical", visible = false, style =
	"ACT2_vertical_flow" }

	radio_section.radioLables.add { type = "label", name = "labelTimeSecond", caption = "Seconds", tooltip = { 'controls.ACT2_IPS_IPM_T', 'seconds' }, visible = false }
	radio_section.radioButtons.add { type = "radiobutton", name = "ACTTimeSecond", tooltip = { 'controls.ACT2_IPS_IPM_T', 'seconds' }, state = true, visible = false }

	radio_section.radioLables.add { type = "label", name = "labelTimeMinute", caption = "Minutes", tooltip = { 'controls.ACT2_IPS_IPM_T', 'minutes' }, visible = false }
	radio_section.radioButtons.add { type = "radiobutton", name = "ACTTimeMinute", tooltip = { 'controls.ACT2_IPS_IPM_T', 'minutes' }, state = false, visible = false }

	--add ingredients
	assembler_group.add { type = "flow" --[[X--]], name = "ingredientsSection", direction = "vertical", visible = false --[[*--]] }
	local ingredients_section = assembler_group.ingredientsSection

	ingredients_section.add { type = "label", name = "sectionLabel", caption = "Ingredients", visible = false --[[*--]] }

	--add products
	assembler_group.add { type = "flow" --[[X--]], name = "productsSection", direction = "vertical", visible = false --[[*--]] }
	local products_section = assembler_group.productsSection

	products_section.add { type = "label", name = "sectionLabel", caption = "Products", visible = false --[[*--]] }

	--add warningGroup
	playersGui["ACT2_frame_" .. playersGui.player_index].add { type = "flow" --[[X--]], name = "warningGroup", direction = "vertical", visible = false --[[*--]] }
	local warning_group = playersGui["ACT2_frame_" .. playersGui.player_index].warningGroup
	warning_group.add { type = "label", name = "warningLabel", caption = "", visible = false --[[*--]] }

	--add machineGroup
	playersGui["ACT2_frame_" .. playersGui.player_index].add { type = "flow" --[[X--]], name = "machineGroup", direction = "vertical", visible = false --[[*--]] }
	local machine_group = playersGui["ACT2_frame_" .. playersGui.player_index].machineGroup

	machine_group.add { type = "label", name = "machineLabel", caption = "Adjust number of machines", tooltip = { 'tooltips.scroll-wheel' }, visible = false --[[*--]] }
	machine_group.add { type = "flow" --[[X--]], name = "sliderSection", direction = "horizontal", tooltip = { 'tooltips.scroll-wheel' }, visible = false --[[*--]] }

	machine_group.sliderSection.add { type = "sprite-button", name = "Sub5-ACT2-sliderButton", tooltip = { 'tooltips.add-sub', "-5", "1", "-31", "-25" }, sprite = spriteCheck(player, "editor_speed_down"), style = "ACT2_buttons", visible = false --[[*--]] }
	machine_group.sliderSection.add { type = "sprite-button", name = "Sub1-ACT2-sliderButton", tooltip = { 'tooltips.add-sub', "-1", { '', { 'tooltips.dn' }, ' ', storage.ACT2[player.name]["max-slider-value"] / 2 }, "-7", "-10" }, sprite = spriteCheck(player, "left_arrow"), style = "ACT2_buttons", visible = false --[[*--]] }

	machine_group.sliderSection.add { type = "slider", name = playersGui.player_index .. "_slider", minimum_value = 1, maximum_value = storage.ACT2[player.name]["max-slider-value"], tooltip = { 'tooltips.scroll-wheel' }, style = "slider", visible = false --[[*--]] }
	--*** --[[ value = 0,--]]--[[truncateNumber(0--[[sliderValue--]], 0)--]]
	machine_group.sliderSection.add { type = "sprite-button", name = "Add1-ACT2-sliderButton", tooltip = { 'tooltips.add-sub', "+1", { '', { 'tooltips.up' }, ' ', storage.ACT2[player.name]["max-slider-value"] / 2 }, "+7", "+10" }, sprite = spriteCheck(player, "right_arrow"), style = "ACT2_buttons", visible = false --[[*--]] }
	machine_group.sliderSection.add { type = "sprite-button", name = "Add5-ACT2-sliderButton", tooltip = { 'tooltips.add-sub', "+5", storage.ACT2[player.name]["max-slider-value"], "+31", "+25" }, sprite = spriteCheck(player, "editor_speed_up"), style = "ACT2_buttons", visible = false --[[*--]] }

	machine_group.sliderSection.add { type = "label", name = "sliderLabel", caption = "", visible = false --[[*--]] }
end

local function run(event)
	--event.gui_type == defines.gui_type.entity
	if not desiredGuiTypeEntity(event) then return end

	local entity = event.entity

	if not desiredEntity(entity) then return end

	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	setsettings(player)
	local guiLocation = storage.ACT2[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation] --top or left	

	local frameName = "ACT2_frame_" .. playerIndex  -- The frame’s name
	
	-- Debug ui reset 
	-- if playersGui[frameName] then
	-- 	playersGui[frameName].destroy()  -- Properly remove the frame
	-- end

	if not playersGui[frameName] then
		setupGui(player, playersGui)
	end

	guiVisibleAttrDescend(playersGui[frameName], false)
	findPrototypeData(player.name)
	local recipe = getRecipe(entity, player.name)
	local assembler_group = playersGui[frameName].assemblerGroup
	if not recipe then --update gui and return
		updateRecipe(assembler_group.recipeRadioWrap.recipeSection, { 'tooltips.reset', entity.localised_name },
			{ 'captions.no-recipe' }, spriteCheck(player, entity.name))
		return
	end
	globalSliderStorage(player.name, recipe.name)

	local minOrSec = determineMinOrSec(assembler_group.recipeRadioWrap.radioSection.radioButtons.ACTTimeSecond)
	--game.print("this is recipe "..serpent.block(recipe))
	updateRecipe(assembler_group.recipeRadioWrap.recipeSection,
		{ 'tooltips.reset', recipe.localised_name },
		{ minOrSec.captions, truncateNumber(math.max(recipe.seconds, 1 / 60) / minOrSec.value,
			conditionalDecimalIncrease(recipe.seconds, 2)) },
		spriteCheck(player, recipe.name))

	updateRadio(assembler_group.recipeRadioWrap.radioSection)

	updateItem(recipe, recipe.ingredients, assembler_group.ingredientsSection, minOrSec)

	updateItem(recipe, recipe.products, assembler_group.productsSection, minOrSec)

	if recipe.is_capped then
		local warning_group = playersGui["ACT2_frame_" .. playersGui.player_index].warningGroup
		if warning_group == nil then
			--game.print("warning_group is nil") --This should never happen as per on_configuration_changed
		else
			updateWarning(warning_group, { 'captions.is-capped' })
		end
	end

	local machine_group = playersGui["ACT2_frame_" .. playersGui.player_index].machineGroup
	updateMachine(machine_group, truncateNumber(storage.ACT2_slider[player.name][recipe.name].value, 0), entity)
end

local function resetACT(event)
	event.entity = game.players[event.player_index].opened
	event.gui_type = defines.gui_type.entity
	run(event)
end

local function changeGuiSliderButtons(event)
	local shi = event.shift
	local alt = event.alt
	local con = event.control

	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	local elementName = event.element.name

	local guiLocation = storage.ACT2[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation] --top or left
	local entity = player.opened
	if not entity then return end
	local recipe = getRecipe(entity, player.name)
	if not recipe then return end
	if shi and not alt and not con then --click with keyboard
		if elementName:find("Sub5") then -- -25
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -25
		elseif elementName:find("Sub1") then -- -10
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -10
		elseif elementName:find("Add1") then -- +10
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 10
		elseif elementName:find("Add5") then -- +25
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 25
		end
	elseif shi and con and not alt then --click with keyboard
		if elementName:find("Sub5") then -- -31
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -31
		elseif elementName:find("Sub1") then -- -7
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -7
		elseif elementName:find("Add1") then -- +7
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 7
		elseif elementName:find("Add5") then -- +31
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 31
		end
	elseif con and not shi and not alt then --click with keyboard
		local settingMaxSliderValue = storage.ACT2[player.name]["max-slider-value"]
		if elementName:find("Sub5") then -- down to 1
			storage.ACT2_slider[player.name][recipe.name].value = 1
		elseif elementName:find("Sub1") then -- down to 50%
			if storage.ACT2_slider[player.name][recipe.name].value >= settingMaxSliderValue / 2 then
				storage.ACT2_slider[player.name][recipe.name].value = settingMaxSliderValue / 2
			end
		elseif elementName:find("Add1") then -- up   to 50%
			if storage.ACT2_slider[player.name][recipe.name].value <= settingMaxSliderValue / 2 then
				storage.ACT2_slider[player.name][recipe.name].value = settingMaxSliderValue / 2
			end
		elseif elementName:find("Add5") then -- up   to max
			storage.ACT2_slider[player.name][recipe.name].value = settingMaxSliderValue
		end
	elseif not shi and not alt and not con then --normal click
		if elementName:find("Sub5") then     -- -5
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -5
		elseif elementName:find("Sub1") then -- -1
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + -1
		elseif elementName:find("Add1") then -- +1
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 1
		elseif elementName:find("Add5") then -- +5
			storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2_slider[player.name][recipe.name].value + 5
		end
	end

	if storage.ACT2_slider[player.name][recipe.name].value < 1 then
		storage.ACT2_slider[player.name][recipe.name].value = 1
	elseif storage.ACT2_slider[player.name][recipe.name].value > storage.ACT2[player.name]["max-slider-value"] then
		storage.ACT2_slider[player.name][recipe.name].value = storage.ACT2[player.name]["max-slider-value"]
	end
	event.gui_type = defines.gui_type.entity
	event.entity = entity
	run(event)
end

local function playerSlid(event)
	if not desiredGuiNameSlider(event) then return end
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	local entity = player.opened
	if not entity then return end

	local recipe = getRecipe(entity, player.name)
	if not recipe then return end
	if storage.ACT2_slider[player.name][recipe.name] then
		if not (math.abs(storage.ACT2_slider[player.name][recipe.name].value - event.element.slider_value) >= storage.ACT2[player.name]["sensitivity-value"] / 10) then return end
		storage.ACT2_slider[player.name][recipe.name].value = event.element.slider_value

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity

		run(event)
	end
end

local function playerClickedGui(event)
	if not (event.element.type == "sprite-button") then return end --restrict what is "clickable" to sprite-buttons.
	--radiobuttons handled in on_gui_checked_state_changed, radiobutton()
	--slider is handled in on_gui_value_changed, playerSlid()
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	findPrototypeData(player.name) -- this can be the fix idk
	local elementName = event.element.name
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
	if event.input_name == "ACT2_IPS_IPM" then
		for k, v in pairs(event.element.children_names) do
			if event.element[v].state == true then
				event.element[v].state = not event.element[v].state
				event.element = event.element[v]
				break
			end
		end
	end
	if event.element.name:find("ACTTime") then
		toggleRadio(event.element)
		local playerIndex = event.player_index
		local player = game.players[playerIndex]
		if not player then return end

		event.entity = player.opened
		event.gui_type = defines.gui_type.entity

		run(event)
	end
end

local function customInputForRadioButton(event)
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	if not player then return end
	setsettings(player)
	local guiLocation = storage.ACT2[player.name]["gui-location"]
	local playersGui = player.gui[guiLocation] --top or left	
	if not playersGui["ACT2_frame_" .. playerIndex] then
		setupGui(player, playersGui)
	end

	event.element = playersGui["ACT2_frame_" .. event.player_index].assemblerGroup.recipeRadioWrap.radioSection
	.radioButtons
	radiobutton(event)
end

local function modChange(event)
	if event.mod_changes == nil then return end
	if event.mod_changes.Actual_Craft_Time_2 == nil then return end

	local previousOldACTModVersion = event.mod_changes.Actual_Craft_Time_2.old_version
	local currentNewACTModVersion = event.mod_changes.Actual_Craft_Time_2.new_version

	if previousOldACTModVersion == nil then return end --mod was installed previously
	if currentNewACTModVersion == nil then return end --mod removed ¯\_(ツ)_/¯

	if tostring(tostring(previousOldACTModVersion) <= tostring(currentNewACTModVersion)) then
		-- mod was updated, check for gui and delete
		for playerIndex, player in pairs(game.players) do
			for _, guiLocation in pairs(player.gui.children) do --top, left and everywhere (everywhere isn't necessary but ¯\_(ツ)_/¯, I don't care)
				if guiLocation["ACT2_frame_" .. playerIndex] then
					guiLocation["ACT2_frame_" .. playerIndex].destroy()
				end
			end
		end
	end
end

script.on_event(defines.events.on_gui_opened, run)

script.on_event(defines.events.on_gui_closed, closeGui)

script.on_event(defines.events.on_gui_click, playerClickedGui)

script.on_event(defines.events.on_gui_value_changed, playerSlid)

script.on_event(defines.events.on_gui_checked_state_changed, radiobutton)

script.on_event("ACT2_IPS_IPM", customInputForRadioButton)

script.on_configuration_changed(modChange)
