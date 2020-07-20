local test_suite = require("test-suite")

--- @param self test_suite
return function(self)
	self:is_equal(self:tests(), {});
	self:is_equal(self:tests_passed(), 1)
	self:is_equal(self:tests_failed(), 0)
	self:is_equal(#self:tests(), 3)
	self:pass();
	local ts = test_suite.new()
	ts:fail();
	ts:did_invoke_pass(type)
	ts:did_invoke_fail(type, "abc")
	ts:assert(false)
	ts:is_equal(true, false)
	ts:not_equal(true, true)
	ts:is_truthy(false)
	ts:is_falsy(true)
	ts:is_equal("abc\r\n\t\0\'\"", "abc")
	ts:is_equal(setmetatable({}, {}), setmetatable({}, {}))
	self:is_equal(ts:tests_failed(), 10)
	self:did_invoke_pass(tonumber, "123")
	self:did_invoke_fail(type)
	self:not_equal(self:tests(), {});
	self:assert(0, "truthy assertion failed");
	self:assert(true, "truthy assertion failed");
	self:is_equal(nil, nil)
	self:is_equal(5, 5)
	self:is_equal(math.pi, math.pi)
	self:is_equal("abc", "abc")
	self:is_equal({ x = 5 }, { x = 5.0 })
	self:is_equal({ [{ x = 5, y = 10, 5, 10 }] = 5}, { [{ 5, y = 10, x = 5, 10 }] = 5})
	self:is_equal(_G, _G)
	self:is_equal(print, print)
	self:not_equal(nil, true)
	self:not_equal(true, false)
	self:not_equal("abc", "abc\0")
	self:not_equal({ x = 5 }, { x = 6 })
	self:not_equal({ x = _G }, { [_G] = 5 })
	self:not_equal(print, error)
	self:is_truthy(true)
	self:is_truthy(0)
	self:is_truthy("")
	self:is_falsy(false)
	self:is_falsy(nil)
end
