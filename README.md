# opentx-ui

User Interface library code for OpenTX

## Example

Please see the included `example.lua` for a full, working example of the script.

## Form

### Usage

Include `form.lua` in your Lua source

```
local form = dofile('/SCRIPTS/LIBRARY/form.lua')
```

Define a form structure and table to hold values

```
local SWITCH_NAMES = { 'sa', 'sb', 'sc', 'sd' }
local BUTTON_OK = -5

local setupForm = {
	{ form.TYPE_INTEGER, 'Throttle Channel', 'ThrottleChannel', 10, 11, 1, 16 },
	{ form.TYPE_LIST, 'Lap Switch', 'LapSwitch', 10, 21, SWITCH_NAMES },
	{ form.TYPE_YES_NO, 'Speak', 'SpeakSounds', 10, 31 },
	{ form.TYPE_BUTTON, 'Ok', BUTTON_OK, 10, 41 }
}

local setup = {
	ThrottleChannel = 1,
	SpeakSounds = true,
	LapSwitch = 2
}
```

Call the `execute` method

```
local function run_func(keyEvent)
	lcd.clear()
	lcd.drawScreenTitle('Menu Example', 1, 1)

	local result = form.execute(setupForm, setup, keyEvent)
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

### Form Layout

The form should be defined as a table of sub-tables. Each sub-table will become a new
form entry. A form entry layout is defined by:

1. Type of entry. See `TYPE_` constants
2. Label to display
3. Value key to read and write to passed in the values parameter of the `execute` method
4. X location of Label
5. Y location of Label
6. Additional Parameters - defined by the `TYPE` of form entry

### Form Types

* `TYPE_INTEGER` -- Contains two additional parameters, `min` and `max`
* `TYPE_STRING` -- Contains one additional parameter, max size
* `TYPE_LIST` -- Contains one additional parameter, an array of list values
* `TYPE_YES_NO` -- No additional parameters
* `TYPE_BUTTON` -- No additional parameters. The `value` part, however, is returned as
  the `event` if pressed. Thus, the `value` of a button should not be any standard `EVT_` values
* `TYPE_TEXT` -- Not an editable field, just text display. Value should be nil
* `TYPE_PIXMAP` -- Not an editable field, just a pixmap display. Label should be
  the full path to the bitmap file. Value should be nil

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

## Widgets

Miscellaneous widgets

### Use

Include `widges.lua` in your Lua source

```
local wig = dofile('/SCRIPTS/LIBRARY/widgets.lua')
```

### drawScrollbar(x, y, h, offset, count, visible)

* **x** -- x location of the scrollbar
* **y** -- y location of the scrollbar
* **h** -- height of the scrollbar
* **offset** -- offset of the scrollbar
* **count** -- number of items the scroll bar represents
* **visible** -- number of items the display shows at one time

An example:

```
--
-- Right side of the screen, on item 5 of 10 and the screen can display
-- 5 items at a time
--

wig.drawScrollbar(211, 0, 63, 5, 10, 5)
```

## Release History

* **Version 0.3.0 -- Jan 14, 2016 (evening)**: String editing now functions, although it
  is not an exact replica of OpenTX string editing, that will come in a future release.
* **Version 0.2.0 -- Jan 14, 2016 (morning)**: First public release, a lot can/will
  change still.
