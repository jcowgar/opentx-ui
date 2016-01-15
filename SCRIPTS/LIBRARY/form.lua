local form = {}

form.TYPE_INTEGER = 0
form.TYPE_STRING = 1
form.TYPE_LIST = 2
form.TYPE_YES_NO = 4
form.TYPE_BUTTON = 5
form.TYPE_TEXT = 6
form.TYPE_PIXMAP = 7

local LAYOUT_TYPE = 1
local LAYOUT_LABEL = 2
local LAYOUT_VALUE = 3
local LAYOUT_X = 4
local LAYOUT_Y = 5
local LAYOUT_FIRST_PARAM = 6

local SPACES = '                              '

local function edit_character(value, position, dir)
	local b = string.byte(value, position)
	b = b + dir
	
	if b < 32 then
		b = 126
	elseif b > 126 then
		b = 32
	end
	
	return string.sub(value, 1, position - 1)..string.char(b)..string.sub(value, position + 1, #value)
end

function form.handle_edit_key_event_integer_real(frm, values, keyEvent, min, max)
	local f = frm[frm.CurrentField]

	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT then
		values[f[LAYOUT_VALUE]] = values[f[LAYOUT_VALUE]] - 1
	elseif keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT then
		values[f[LAYOUT_VALUE]] = values[f[LAYOUT_VALUE]] + 1
	elseif keyEvent == EVT_EXIT_BREAK or keyEvent == EVT_ENTER_BREAK then
		frm.IsEditing = false
		return 0
	end
	
	if values[f[LAYOUT_VALUE]] < min then
		values[f[LAYOUT_VALUE]] = max
	elseif values[f[LAYOUT_VALUE]] > max then
		values[f[LAYOUT_VALUE]] = min
	end
end

function form.handle_edit_key_event_integer(frm, values, keyEvent)
	local f = frm[frm.CurrentField]
	local min = f[LAYOUT_FIRST_PARAM]
	local max = f[LAYOUT_FIRST_PARAM + 1]
	
	return form.handle_edit_key_event_integer_real(frm, values, keyEvent, min, max)
end

function form.handle_edit_key_event_string(frm, values, keyEvent)
	local f = frm[frm.CurrentField]
	
	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT then
		values[f[LAYOUT_VALUE]] = edit_character(
			values[f[LAYOUT_VALUE]],
			frm.EditColumn, -1)

	elseif keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT then
		values[f[LAYOUT_VALUE]] = edit_character(
			values[f[LAYOUT_VALUE]],
			frm.EditColumn, 1)

	elseif keyEvent == EVT_ENTER_BREAK then
		frm.EditColumn = frm.EditColumn + 1
		
	elseif keyEvent == EVT_EXIT_BREAK then
		frm.IsEditing = false
		return 0
	end
	
	if frm.EditColumn > f[LAYOUT_FIRST_PARAM] then
		frm.IsEditing = false
		return 0
	end
	
	local value = values[f[LAYOUT_VALUE]]
	
	-- Pad our value with spaces at the end, only for display purposes
	value = value .. string.sub(SPACES, #value, #value + f[LAYOUT_FIRST_PARAM])
	
	for idx = 1, #value do
		local ch = string.sub(value, idx, idx)
		local attributes = 0
		if idx == frm.EditColumn then
			attributes = INVERS
		end
		
		local x = ((idx - 1) * 7) + frm.ValueColumn
		local y = f[LAYOUT_Y]
		
		lcd.drawText(x, y, ch, attributes)
	end
end

function form.handle_edit_key_event_list(frm, values, keyEvent)
	local f = frm[frm.CurrentField]
	local min = 1
	local max = #f[LAYOUT_FIRST_PARAM]
	
	return form.handle_edit_key_event_integer_real(frm, values, keyEvent, min, max)
end

function form.handle_edit_key_event_yes_no(frm, values, keyEvent)
	local f = frm[frm.CurrentField]

	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT or
		keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT
	then
		values[f[LAYOUT_VALUE]] = values[f[LAYOUT_VALUE]] ~= true
	elseif keyEvent == EVT_EXIT_BREAK or keyEvent == EVT_ENTER_BREAK then
		frm.IsEditing = false
		return 0
	end
end

function form.handle_edit_key_event(frm, values, keyEvent)
	local fType = frm[frm.CurrentField][LAYOUT_TYPE]
	
	if fType == form.TYPE_INTEGER then
		return form.handle_edit_key_event_integer(frm, values, keyEvent)
	elseif fType == form.TYPE_STRING then
		return form.handle_edit_key_event_string(frm, values, keyEvent)
	elseif fType == form.TYPE_LIST then
		return form.handle_edit_key_event_list(frm, values, keyEvent)
	elseif fType == form.TYPE_YES_NO then
		return form.handle_edit_key_event_yes_no(frm, values, keyEvent)
	end
end

function form.handle_nav_key_event(frm, values, keyEvent)
	local move = 0
	
	if keyEvent == EVT_MINUS_FIRST or keyEvent == EVT_MINUS_RPT then
		move = -1
	elseif keyEvent == EVT_PLUS_FIRST or keyEvent == EVT_PLUS_RPT then
		move = 1
	end
	
	if move ~= 0 then
		frm.CurrentField = frm.CurrentField + move
	
		if frm.CurrentField < 1 then
			frm.CurrentField = #frm
		elseif frm.CurrentField > #frm then
			frm.CurrentField = 1
		end
		
		local fType = frm[frm.CurrentField][LAYOUT_TYPE]
		
		if fType == form.TYPE_PIXMAP or 
			fType == form.TYPE_TEXT
		then
			return form.handle_nav_key_event(frm, values, keyEvent)
		end
				
		return 0

	elseif keyEvent == EVT_ENTER_BREAK then
		if frm[frm.CurrentField][LAYOUT_TYPE] == form.TYPE_BUTTON then
			return frm[frm.CurrentField][LAYOUT_VALUE]
		else
			frm.IsEditing = true
			frm.EditColumn = 1
			
			return 0
		end
	end

	return keyEvent
end

function form.execute(frm, values, keyEvent)
	if frm.CurrentField == nil then
		-- Configure the menu editor for the first time
		
		frm.IsEditing = false
		
		-- Find the first selectable field
		for fIndex = 1, #frm do
			local f = frm[fIndex]
			local fType = f[LAYOUT_TYPE]
			
			if fType ~= form.TYPE_PIXMAP and fType ~= form.TYPE_TEXT then
				frm.CurrentField = fIndex
				break
			end
		end
	end
	
	if frm.IsEditing then
		form.handle_edit_key_event(frm, values, keyEvent)
	else
		local r = form.handle_nav_key_event(frm, values, keyEvent)
		
		if r ~= 0 then
			return r
		end
	end
		
	for fIndex = 1, #frm do
		local f = frm[fIndex]
		local fType = f[LAYOUT_TYPE]
		local fLabel = f[LAYOUT_LABEL]
		local attributes = 0

		local value = values[f[LAYOUT_VALUE]]
		if fType == form.TYPE_INTEGER then
			value = string.format('%d', value)
		
		elseif fType == form.TYPE_STRING then
			-- We do not want to draw the value here if we are editing this string
			if fIndex == frm.CurrentField and frm.IsEditing then
				value = nil
			end
			
		elseif fType == form.TYPE_LIST then
			value = f[LAYOUT_FIRST_PARAM][value]

		elseif fType == form.TYPE_YES_NO then
			if value then
				value = 'Yes'
			else
				value = 'No'
			end

		elseif fType == form.TYPE_BUTTON then
			value = nil
			
			if fIndex == frm.CurrentField then
				attributes = INVERS
			end
			
		elseif fType == form.TYPE_TEXT then
			value = nil
		
			attributes = f[LAYOUT_FIRST_PARAM]
	
		elseif fType == form.TYPE_PIXMAP then
			lcd.drawPixmap(f[LAYOUT_X], f[LAYOUT_Y], fLabel)
			fLabel = nil
			
		else
			error('Unknown menu type:' .. fType .. ' for menu index ' .. fIndex)
		end
		
		if fLabel ~= nil then
			lcd.drawText(f[LAYOUT_X], f[LAYOUT_Y], fLabel, attributes)
			
			if value ~= nil then
				local x = frm.ValueColumn
				if x == nil then
					x = lcd.getLastPos() + 3
				end

				attributes = 0
						
				if fIndex == frm.CurrentField then
					attributes = attributes + INVERS
			
					if frm.IsEditing then
						attributes = attributes + BLINK
					end
				end

				lcd.drawText(x, f[LAYOUT_Y], value, attributes)
			end
		end
	end
end

return form