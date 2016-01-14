--
-- Script constants/setup
-- 

local BUTTON_CANCEL = 0
local BUTTON_SAVE = 1
local SWITCH_NAMES = { 'sa', 'sb', 'sc', 'sd', 'se', 'sf', 'sg', 'sh' }

local config = {
	ThrottleChannel = 1,
	AileronChannel = 2,
	SpeakSounds = true,
	LapSwitch = 3
}

--
-- Reusable menu code
--

local m = dofile('/SCRIPTS/LIBRARY/menu.lua')

local menu = {
	ValueColumn = 115,
	{ m.TYPE_INTEGER, 'Throttle Channel', 'ThrottleChannel', 10, 11, 1, 16 },
	{ m.TYPE_INTEGER, 'Aileron Channel', 'AileronChannel', 10, 21, 1, 16 },
	{ m.TYPE_YES_NO, 'Speak', 'SpeakSounds', 10, 31 },
	{ m.TYPE_LIST, 'Lap Switch', 'LapSwitch', 10, 41, SWITCH_NAMES },
	{ m.TYPE_BUTTON, 'Save', BUTTON_SAVE, 10, 51 },
	{ m.TYPE_BUTTON, 'Cancel', BUTTON_CANCEL, 50, 51 }
}

--
-- Telemetry Script
--

local function init_func(keyEvent)
	-- Read configuration file
end

local function run_func(keyEvent)
	lcd.clear()
	lcd.drawScreenTitle('Menu Example', 1, 1)

	local button = m.execute(menu, config, keyEvent)
	if button == BUTTON_CANCEL then
		-- User press Cancel
	elseif button == BUTTON_SAVE then
		-- User pressed Save
	elseif button == nil then
		-- User did not press a button
	end
end

return { init=init_func, run=run_func }
