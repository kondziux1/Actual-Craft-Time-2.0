local ACTStorage = require("utils.storage")
local ACTGui = require("gui.gui")

local function onInit()
	ACTStorage.initStorage()
	for _, player in pairs(game.players) do
		if player and player.valid then
			ACTStorage.setsettings(player)
		end
	end
end

local function onConfigurationChanged(event)
	ACTStorage.initStorage()
	if event.mod_changes and event.mod_changes.Actual_Craft_Time_2 then
		for _, player in pairs(game.players) do
			if player and player.valid then
				ACTGui.destroyFrame(player)
				ACTStorage.setsettings(player)
			end
		end
	end
end

local function onPlayerCreated(event)
	local player = game.get_player(event.player_index)
	if player and player.valid then
		ACTStorage.setsettings(player)
	end
end

local function onPlayerRemoved(event)
	if event.player_index then
		local player = game.get_player(event.player_index)
		local playerName = player and player.valid and player.name
		if playerName then
			ACTStorage.removePlayer(playerName)
		end
	end
end

local function onRuntimeModSettingChanged(event)
	if event.player_index and event.setting and event.setting:find("ACT2") then
		local player = game.get_player(event.player_index)
		if player and player.valid then
			ACTStorage.setsettings(player)
			ACTGui.destroyFrame(player)
		end
	end
end

-- Lifecycle hooks
script.on_init(onInit)
script.on_configuration_changed(onConfigurationChanged)

-- Player events
script.on_event(defines.events.on_player_created, onPlayerCreated)
script.on_event(defines.events.on_player_removed, onPlayerRemoved)
script.on_event(defines.events.on_runtime_mod_setting_changed, onRuntimeModSettingChanged)

-- GUI events
script.on_event(defines.events.on_gui_opened, ACTGui.onGuiOpened)
script.on_event(defines.events.on_gui_closed, ACTGui.onGuiClosed)
script.on_event(defines.events.on_gui_click, ACTGui.onGuiClick)
script.on_event(defines.events.on_gui_value_changed, ACTGui.onGuiValueChanged)
script.on_event(defines.events.on_gui_checked_state_changed, ACTGui.onGuiCheckedStateChanged)
script.on_event(defines.events.on_gui_location_changed, ACTGui.onGuiLocationChanged)
script.on_event("ACT2_IPS_IPM", ACTGui.onCustomInput)
