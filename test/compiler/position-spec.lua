local position = require("compiler.position")

--- @param self test_suite
return function(self)
	self:is_equal(position.new(10, 15), { line = 10, column = 15 })
	self:is_equal(position.zero(), { line = 0, column = 0 })
end
