local widgets = {}

local function vlineStrip(x, y, h, pattern, flags)
	lcd.drawLine(x, y, x, y + h, pattern, flags)
end

function widgets.drawScrollbar(x, y, h, offset, count, visible)
	vlineStrip(x, y, h, DOTTED, 0)

	local yofs = (h * offset) / count
	local yhgt = (h * visible) / count
	if yhgt + yofs > h then
		yhgt = h - yofs
	end
	
	vlineStrip(x, y + yofs, yhgt, SOLID, FORCE)
end

return widgets
