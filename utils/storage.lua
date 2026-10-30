local ACTStorage = {}

function ACTStorage.initStorage()
	if not storage.ACT2 then
		storage.ACT2 = {}
	end
	if not storage.ACT2_slider then
		storage.ACT2_slider = {}
	end
end

function ACTStorage.globalSliderStorage(playerName, recipeName)
	if not playerName or not recipeName then return end
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

function ACTStorage.setsettings(player)
	if not player or not player.valid then return end
	if not storage.ACT2 then
		storage.ACT2 = {}
	end

	local modSettings = player.mod_settings
	local guiLocation = modSettings["ACT2-Gui-Location"] and modSettings["ACT2-Gui-Location"].value or "screen"
	local simpleText = modSettings["ACT2-simple-text"] and modSettings["ACT2-simple-text"].value or false
	local maxSlider = modSettings["ACT2-max-slider-value"] and modSettings["ACT2-max-slider-value"].value or 200
	local sensitivity = modSettings["ACT2-slider-sensitivity"] and modSettings["ACT2-slider-sensitivity"].value or 5
	local showQuality = true
	if modSettings["ACT2-show-quality-chance"] then
		showQuality = modSettings["ACT2-show-quality-chance"].value
	end
	local beltStackMode = true
	if modSettings["ACT2-belt-stack-mode"] then
		beltStackMode = modSettings["ACT2-belt-stack-mode"].value
	end

	if not storage.ACT2[player.name] then
		storage.ACT2[player.name] = {
			["gui-location"] = guiLocation,
			["simple-text"] = simpleText,
			["max-slider-value"] = maxSlider,
			["sensitivity-value"] = sensitivity,
			["window-location"] = { x = 20, y = 80 },
			["show-quality-chance"] = showQuality,
			["belt-stack-mode"] = beltStackMode,
		}
	else
		local s = storage.ACT2[player.name]
		if s["gui-location"] ~= guiLocation then s["gui-location"] = guiLocation end
		if s["simple-text"] ~= simpleText then s["simple-text"] = simpleText end
		if s["max-slider-value"] ~= maxSlider then s["max-slider-value"] = maxSlider end
		if s["sensitivity-value"] ~= sensitivity then s["sensitivity-value"] = sensitivity end
		if not s["window-location"] then s["window-location"] = { x = 20, y = 80 } end
		if s["show-quality-chance"] == nil then s["show-quality-chance"] = showQuality end
		if s["belt-stack-mode"] == nil then s["belt-stack-mode"] = beltStackMode end
	end
end

function ACTStorage.getSettings(playerName)
	if storage.ACT2 and storage.ACT2[playerName] then
		return storage.ACT2[playerName]
	end
	return {
		["gui-location"] = "screen",
		["simple-text"] = false,
		["max-slider-value"] = 200,
		["sensitivity-value"] = 5,
		["window-location"] = { x = 20, y = 80 },
		["show-quality-chance"] = true,
		["belt-stack-mode"] = true,
	}
end

function ACTStorage.getTimeMode(playerName)
	if storage.ACT2 and storage.ACT2[playerName] and storage.ACT2[playerName]["time-mode"] then
		return storage.ACT2[playerName]["time-mode"]
	end
	return "second"
end

function ACTStorage.setTimeMode(playerName, mode)
	if not playerName then return end
	if not storage.ACT2 then storage.ACT2 = {} end
	if not storage.ACT2[playerName] then storage.ACT2[playerName] = {} end
	storage.ACT2[playerName]["time-mode"] = mode
end

function ACTStorage.cycleTimeMode(playerName)
	local current = ACTStorage.getTimeMode(playerName)
	local nextMode = "second"
	if current == "second" then
		nextMode = "minute"
	elseif current == "minute" then
		nextMode = "tick"
	else
		nextMode = "second"
	end
	ACTStorage.setTimeMode(playerName, nextMode)
	return nextMode
end

function ACTStorage.getQualityToggle(playerName)
	if storage.ACT2 and storage.ACT2[playerName] and storage.ACT2[playerName]["show-quality-chance"] ~= nil then
		return storage.ACT2[playerName]["show-quality-chance"]
	end
	return true
end

function ACTStorage.setQualityToggle(playerName, value)
	if not playerName then return end
	if not storage.ACT2 then storage.ACT2 = {} end
	if not storage.ACT2[playerName] then storage.ACT2[playerName] = {} end
	storage.ACT2[playerName]["show-quality-chance"] = value
end

function ACTStorage.getBeltStackValue(playerName, maxStack)
	maxStack = maxStack or 4
	if storage.ACT2 and storage.ACT2[playerName] then
		local val = storage.ACT2[playerName]["belt-stack-value"]
		if type(val) == "number" then
			if val < 1 then return 1 end
			if val > maxStack then return maxStack end
			return val
		elseif storage.ACT2[playerName]["belt-stack-mode"] == false then
			return 1
		end
	end
	return maxStack
end

function ACTStorage.setBeltStackValue(playerName, value)
	if not playerName then return end
	if not storage.ACT2 then storage.ACT2 = {} end
	if not storage.ACT2[playerName] then storage.ACT2[playerName] = {} end
	storage.ACT2[playerName]["belt-stack-value"] = value
	storage.ACT2[playerName]["belt-stack-mode"] = (value > 1)
end

function ACTStorage.getBeltStackToggle(playerName)
	return ACTStorage.getBeltStackValue(playerName, 4) > 1
end

function ACTStorage.setBeltStackToggle(playerName, value)
	ACTStorage.setBeltStackValue(playerName, value and 4 or 1)
end

function ACTStorage.getWindowLocation(playerName)
	if storage.ACT2 and storage.ACT2[playerName] and storage.ACT2[playerName]["window-location"] then
		return storage.ACT2[playerName]["window-location"]
	end
	return { x = 20, y = 80 }
end

function ACTStorage.setWindowLocation(playerName, location)
	if not playerName or not location then return end
	if not storage.ACT2 then storage.ACT2 = {} end
	if not storage.ACT2[playerName] then storage.ACT2[playerName] = {} end
	storage.ACT2[playerName]["window-location"] = { x = location.x, y = location.y }
end

function ACTStorage.removePlayer(playerName)
	if storage.ACT2 and storage.ACT2[playerName] then
		storage.ACT2[playerName] = nil
	end
	if storage.ACT2_slider and storage.ACT2_slider[playerName] then
		storage.ACT2_slider[playerName] = nil
	end
end

return ACTStorage
