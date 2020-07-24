local position = require("compiler.position")
local diagnostic = require("compiler.diagnostic")

--- @param self test_suite
return function(self)
	self:is_equal(diagnostic.new("test", position.new(10, 15)), { message = "test", origin = position.new(10, 15) })
end
