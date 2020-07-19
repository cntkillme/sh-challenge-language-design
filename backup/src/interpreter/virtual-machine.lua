--- Virtual Machine Class
-- @author <your name>

local virtual_machine = {}
virtual_machine.__index = virtual_machine

function virtual_machine.new(path)
	-- @implement
	return setmetatable({
		-- @implement additional instance fields if necessary
	}, virtual_machine)
end

-- @implement additional methods, static fields, and/or static methods if necessary

return virtual_machine
