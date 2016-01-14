# opentx-ui

User Interface library code for OpenTX

## Example

Please see the included `example.lua` for a full, working example of the script.

## Menu

### Usage

Include `menu.lua` in your Lua source

```
local menu = dofile('/SCRIPTS/LIBRARY/menu.lua')
```

Define a menu structure and table to hold values

```
local SWITCH_NAMES = { 'sa', 'sb', 'sc', 'sd' }
local BUTTON_OK = -5

local setupMenu = {
	ValueColumn = 115,
	{ menu.TYPE_INTEGER, 'Throttle Channel', 'ThrottleChannel', 10, 11, 1, 16 },
	{ m.TYPE_LIST, 'Lap Switch', 'LapSwitch', 10, 21, SWITCH_NAMES },
	{ menu.TYPE_YES_NO, 'Speak', 'SpeakSounds', 10, 31 },
	{ menu.TYPE_BUTTON, 'Ok', BUTTON_OK, 10, 41 }
}

local setup = {
	ThrottleChannel = 1,
	SpeakSounds = true,
	LapSwitch = 2
}
```

Call the `execute` method of the menu class

```
local function run_func(keyEvent)
	lcd.clear()
	lcd.drawScreenTitle('Menu Example', 1, 1)

	local result = menu.execute(setupMenu, setup, keyEvent)
end
```

Handle any key event that falls through the menu system

```
if result == EVT_MENU_BREAK then
	-- blah
elseif result == BUTTON_OK then
	-- OK button was pressed
end
```

### Menu Layout

The menu should be defined as a table of sub-tables. Each sub-table will become a new
menu entry. A menu entry layout is defined by:

1. Type of menu entry. See `TYPE_` constants
2. Label to display
3. Value key to read and write to passed in the values parameter of the `execute` method
4. X location of Label
5. Y location of Label
6. Additional Parameters - defined by the `TYPE` of menu entry

### Menu Types

* `TYPE_INTEGER` -- Contains two additional parameters, `min` and `max`
* `TYPE_STRING` -- Not yet supported
* `TYPE_LIST` -- Contains one additional parameter, an array of list values
* `TYPE_YES_NO` -- No additional parameters
* `TYPE_BUTTON` -- No additional parameters. The `value` part, however, is returned as
  the `event` if pressed. Thus, the `value` of a button should not be any standard `EVT_` values

## Config

Read and write configuration files based on a table

### Usage

Include `config.lua` in your Lua source

```
local config = dofile('/SCRIPTS/LIBRARY/config.lua')
```

Create a configuration table with default values

```
local setup = {
	ThrottleChannel = 1,
	SpeakSounds = true,
	LapSwitch = 3
}
```

Load load and save your configuration from disk

```
local function do_something()
	setup = config.read('/example.cfg', setup)
	config.write('/example.cfg', setup)
end
```


## Release History

* **Version 0.2.0 -- Jan 14, 2016**: First public release, a lot can/will change still.
