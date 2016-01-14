local config = {}

function config.write(filename, cfg)
	local f = io.open(filename, 'w')
	if f == nil then
		return false
	end
	
	for k,v in pairs(cfg) do
		io.write(f, k .. '=' .. tostring(v) .. "\n")
	end

	io.close(f)
	
	return true
end

function config.read(filename, cfg)
	--
	-- OpenTX Lua throws an error if you attempt to open a file that does not exist:
	--
	-- f_open(/Users/jeremy/Documents/RC/Taranis-X9E-SD/LAPTIME.cfg) = INVALID_NAME
	-- f_close(0x1439291e05400000) (FIL:0x114392828)
	-- PANIC: unprotected error in call to Lua API ((null))
	--
	-- Thus, let's open it in append mode, which should create a blank file if it does
	-- not yet exist.
	--
	
	local f = io.open(filename, 'a')
	if f ~= nil then
		io.close(f)
	end
	
	f = io.open(filename, 'r')
	if f == nil then
		return cfg
	end

	local content = io.read(f, 16384)
	io.close(f)
	
	for value in string.gmatch(content, '([^\n]+)') do
		local k,v = string.match(value, '([^=]+)=(.+)')
		
		if k ~= nil and v ~= nil then
			if v == 'true' then
				v = true
			elseif v == 'false' then
				v = false
			else
				local tmp = tonumber(v)
				if tmp ~= nil then
					v = tmp
				end
			end
			
			cfg[k] = v
		end
	end
	
	return cfg
end

return config