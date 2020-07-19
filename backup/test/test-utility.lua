local utility = require("utility")

return function(test)
	test:equal(test:invoke_pass(utility.copy, nil), nil)
	test:equal(test:invoke_pass(utility.copy, 0), 0)
	test:equal(test:invoke_pass(utility.copy, "string"), "string")
	local t1 = table.pack(1, nil, 2, 3, nil)
	local t1c = test:invoke_pass(utility.copy, t1)

	for k, v in pairs(t1) do
		test:equal(v, t1c[k])
		t1c[k] = nil
	end

	test:equal(next(t1c), nil)
	setmetatable(t1, {__index = {}})
	t1c = test:invoke_pass(utility.copy, t1)

	for k, v in pairs(t1) do
		test:equal(v, t1c[k])
		t1c[k] = nil
	end

	test:equal(next(t1c), nil)
	test:equal(getmetatable(t1c), getmetatable(t1))
	setmetatable(t1, {__metatable = {}})

	do
		local _print = print
		local warningPrinted = false

		function _G.print(...)
			if ... == "metatable may be inaccurate, __metatable is set" then
				warningPrinted = true
			else
				_print(...)
			end
		end

		test:invoke_pass(utility.copy, t1)
		test:truthy(warningPrinted)
		_G.print = _print
	end

	t1 = {}
	t1c = {}
	t1[t1c] = t1
	t1c[t1] = t1c
	local t2 = test:invoke_pass(utility.copy, t1)
	local t2c = next(t2)
	test:equal(t2[t2c], t2)
	test:equal(t2c[t2], t2c)
	test:not_equal(t1, t2)
	test:not_equal(t1, t2c)
	test:not_equal(t1c, t2)
	test:not_equal(t1c, t2c)
end
