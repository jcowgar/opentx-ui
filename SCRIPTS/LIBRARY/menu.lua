local menu = {}

menu.TYPE_INTEGER = 0
menu.TYPE_STRING = 1
menu.TYPE_LIST = 2
menu.TYPE_YES_NO = 4
menu.TYPE_BUTTON = 5

local LAYOUT_TYPE = 1
local LAYOUT_LABEL = 2
local LAYOUT_VALUE = 3
local LAYOUT_X = 4
local LAYOUT_Y = 5
local LAYOUT_FIRST_PARAM = 6

function menu.handle_edit_key_event_integer_real(mnu, values, keyEvent, min, max)
	local m = mnu[mnu.CurrentField]

	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT then
		values[m[LAYOUT_VALUE]] = values[m[LAYOUT_VALUE]] - 1
	elseif keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT then
		values[m[LAYOUT_VALUE]] = values[m[LAYOUT_VALUE]] + 1
	elseif keyEvent == EVT_EXIT_BREAK or keyEvent == EVT_ENTER_BREAK then
		mnu.IsEditing = false
		return 0
	end
	
	if values[m[LAYOUT_VALUE]] < min then
		values[m[LAYOUT_VALUE]] = max
	elseif values[m[LAYOUT_VALUE]] > max then
		values[m[LAYOUT_VALUE]] = min
	end
end

function menu.handle_edit_key_event_integer(mnu, values, keyEvent)
	local m = mnu[mnu.CurrentField]
	local min = m[LAYOUT_FIRST_PARAM]
	local max = m[LAYOUT_FIRST_PARAM + 1]
	
	return menu.handle_edit_key_event_integer_real(mnu, values, keyEvent, min, max)
end

function menu.handle_edit_key_event_string(mnu, values, keyEvent)
	local m = mnu[mnu.CurrentField]
end

function menu.handle_edit_key_event_list(mnu, values, keyEvent)
	local m = mnu[mnu.CurrentField]
	local min = 1
	local max = #m[LAYOUT_FIRST_PARAM]
	
	return menu.handle_edit_key_event_integer_real(mnu, values, keyEvent, min, max)
end

function menu.handle_edit_key_event_yes_no(mnu, values, keyEvent)
	local m = mnu[mnu.CurrentField]

	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT or
		keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT
	then
		values[m[LAYOUT_VALUE]] = values[m[LAYOUT_VALUE]] ~= true
	elseif keyEvent == EVT_EXIT_BREAK or keyEvent == EVT_ENTER_BREAK then
		mnu.IsEditing = false
		return 0
	end
end

function menu.handle_edit_key_event(mnu, values, keyEvent)
	local mType = mnu[mnu.CurrentField][LAYOUT_TYPE]
	
	if mType == menu.TYPE_INTEGER then
		return menu.handle_edit_key_event_integer(mnu, values, keyEvent)
	elseif mType == menu.TYPE_STRING then
		return menu.handle_edit_key_event_string(mnu, values, keyEvent)
	elseif mType == menu.TYPE_LIST then
		return menu.handle_edit_key_event_list(mnu, values, keyEvent)
	elseif mType == menu.TYPE_YES_NO then
		return menu.handle_edit_key_event_yes_no(mnu, values, keyEvent)
	end
end

function menu.handle_nav_key_event(mnu, values, keyEvent)
	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT then
		mnu.CurrentField = mnu.CurrentField - 1
	
		if mnu.CurrentField < 1 then
			mnu.CurrentField = #mnu
		end
		
		return 0

	elseif keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT then
		mnu.CurrentField = mnu.CurrentField + 1
	
		if mnu.CurrentField > #mnu then
			mnu.CurrentField = 1
		end
		
		return 0

	elseif keyEvent == EVT_ENTER_BREAK then
		if mnu[mnu.CurrentField][LAYOUT_TYPE] == menu.TYPE_BUTTON then
			return mnu[mnu.CurrentField][LAYOUT_VALUE]
		else
			mnu.IsEditing = true
			
			return 0
		end
	end

	return keyEvent
end

function menu.execute(mnu, values, keyEvent)
	if mnu.CurrentField == nil then
		-- Configure the menu editor for the first time
		
		mnu.CurrentField = 1
		mnu.IsEditing = false
	end
	
	if mnu.IsEditing then
		menu.handle_edit_key_event(mnu, values, keyEvent)
	else
		local r = menu.handle_nav_key_event(mnu, values, keyEvent)
		
		if r ~= 0 then
			return r
		end
	end
		
	for mIndex = 1, #mnu do
		local m = mnu[mIndex]
		local mType = m[LAYOUT_TYPE]
		local mLabel = m[LAYOUT_LABEL]
		local attributes = 0
		
		local value = values[m[LAYOUT_VALUE]]
		if mType == menu.TYPE_INTEGER then
			value = string.format('%d', value)
		
		elseif mType == menu.TYPE_STRING then
			-- nothing to do
			
		elseif mType == menu.TYPE_LIST then
			value = m[LAYOUT_FIRST_PARAM][value]

		elseif mType == menu.TYPE_YES_NO then
			if value then
				value = 'Yes'
			else
				value = 'No'
			end

		elseif mType == menu.TYPE_BUTTON then
			value = nil
			
			if mIndex == mnu.CurrentField then
				attributes = INVERS
			end

		else
			error('Unknown menu type:' .. mType .. ' for menu index ' .. mIndex)
		end
		
		lcd.drawText(m[LAYOUT_X], m[LAYOUT_Y], mLabel, attributes)

		if value ~= nil then
			local x = mnu.ValueColumn
			if x == nil then
				x = lcd.getLastPos() + 3
			end
			
			attributes = 0
						
			if mIndex == mnu.CurrentField then
				attributes = attributes + INVERS
			
				if mnu.IsEditing then
					attributes = attributes + BLINK
				end
			end

			lcd.drawText(x, m[LAYOUT_Y], value, attributes)
		end
	end
end

return menu