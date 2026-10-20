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
	local guiLocation = modSettings["ACT2-Gui-Location"] and modSettings["ACT2-Gui-Location"].value or "top"
	local simpleText = modSettings["ACT2-simple-text"] and modSettings["ACT2-simple-text"].value or false
	local maxSlider = modSettings["ACT2-max-slider-value"] and modSettings["ACT2-max-slider-value"].value or 200
	local sensitivity = modSettings["ACT2-slider-sensitivity"] and modSettings["ACT2-slider-sensitivity"].value or 5

	if not storage.ACT2[player.name] then
		storage.ACT2[player.name] = {
			["gui-location"] = guiLocation,
			["simple-text"] = simpleText,
			["max-slider-value"] = maxSlider,
			["sensitivity-value"] = sensitivity,
		}
	else
		local s = storage.ACT2[player.name]
		if s["gui-location"] ~= guiLocation then s["gui-location"] = guiLocation end
		if s["simple-text"] ~= simpleText then s["simple-text"] = simpleText end
		if s["max-slider-value"] ~= maxSlider then s["max-slider-value"] = maxSlider end
		if s["sensitivity-value"] ~= sensitivity then s["sensitivity-value"] = sensitivity end
	end
end

function ACTStorage.getSettings(playerName)
	if storage.ACT2 and storage.ACT2[playerName] then
		return storage.ACT2[playerName]
	end
	return {
		["gui-location"] = "top",
		["simple-text"] = false,
		["max-slider-value"] = 200,
		["sensitivity-value"] = 5,
	}
end

function ACTStorage.removePlayer(playerName)
	if storage.ACT2 and storage.ACT2[playerName] then
		storage.ACT2[playerName] = nil
	end
	if storage.ACT2_slider and storage.ACT2_slider[playerName] then
		storage.ACT2_slider[playerName] = nil
	end
end

function ACTStorage.getSettings(playerName)
	if storage.ACT2 and storage.ACT2[playerName] then
		return storage.ACT2[playerName]
	end
	return {
		["gui-location"] = "top",
		["simple-text"] = false,
		["max-slider-value"] = 200,
		["sensitivity-value"] = 5,
	}
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