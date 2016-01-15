--
-- Script constants/setup
-- 

--
-- Reusable code
--

local m = dofile('/SCRIPTS/LIBRARY/menu.lua')
local cfg = dofile('/SCRIPTS/LIBRARY/config.lua')
local wig = dofile('/SCRIPTS/LIBRARY/widgets.lua')

--
-- My menu
--

local BUTTON_CANCEL = -1
local BUTTON_SAVE = -2
local SWITCH_NAMES = { 'sa', 'sb', 'sc', 'sd', 'se', 'sf', 'sg', 'sh' }

local menu = {
	ValueColumn = 115,
	{ m.TYPE_STRING, 'Racer Name', 'RacerName', 10, 11, 12 },
	{ m.TYPE_INTEGER, 'Throttle Channel', 'ThrottleChannel', 10, 21, 1, 16 },
	{ m.TYPE_YES_NO, 'Speak', 'SpeakSounds', 10, 31 },
	{ m.TYPE_LIST, 'Lap Switch', 'LapSwitch', 10, 41, SWITCH_NAMES },
	{ m.TYPE_BUTTON, 'Save', BUTTON_SAVE, 10, 51 },
	{ m.TYPE_BUTTON, 'Cancel', BUTTON_CANCEL, 50, 51 }
}

--
-- My configuration
--

local CONFIG_FILENAME = '/example.cfg'

local config = {
	ThrottleChannel = 1,
	SpeakSounds = true,
	LapSwitch = 3,
	RacerName = 'No Name'
}

--
-- Telemetry Script
--

local function init_func(keyEvent)
	config = cfg.read(CONFIG_FILENAME, config)
end

local function run_func(keyEvent)
	lcd.clear()
	lcd.drawScreenTitle('Menu Example', 1, 1)
	
	local button = m.execute(menu, config, keyEvent)
	if button == BUTTON_CANCEL then
		-- User press Cancel
		playTone(200, 400, 0)
	
	elseif button == BUTTON_SAVE then
		-- User pressed Save
		playTone(600, 400, 0)
	
		cfg.write(CONFIG_FILENAME, config)
	
	elseif button == nil then
		-- User did not press a button
	end
end

return { init=init_func, run=run_func }
