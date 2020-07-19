--- Defines the environment for a set of tests.
--- @class
local test_suite = {}
test_suite.__index = test_suite

-- Forward declarations
local escape_char
local prettify_table

--- Primary constructor.
--- @return test_suite
function test_suite.new()
	return setmetatable({
		_tests_passed = 0,
		_tests_failed = 0
	}, test_suite)
end

--- Returns a readable string for values in the following manner:
---  - a `value` of type `nil`, `boolean`, and `number` results in `tostring(value)`,
---  - a `value` of type `string` results in a string wrapped in double quotes with all double quotes and binary data escaped,
---  - a `value` of type `table` results in a string representing the table with array values prettified followed by dictionary pairs prettified,
---  - a `value` of type `function` with a definite source results in `<function: name (namewhat) at source:linedefined>`,
---  - and any other `value` results in `<tostring(value)>`.
--- @param value any
--- @return string
function test_suite.prettify(value)
	local valueType = type(value)

	if valueType == "nil" or valueType == "boolean" or valueType == "number" then
		return tostring(value)
	elseif valueType == "string" then -- escape quotes and binary data
		return '"' .. valueType:gsub('[%c"]', escape_char) .. '"'
	elseif valueType == "table" then
		return prettify_table(value)
	elseif valueType == "function" and debug.getinfo(value, "n").namewhat ~= "" then
		local info = debug.getinfo(value, "Sn")

		return ("<function: %s (%s) at %s:%d>"):format(
			info.name,
			info.namewhat,
			info.short_src or "<null>",
			info.linedefined or 0
		);
	else
		return "<" .. tostring(value) .. ">"
	end
end


--- Returns the total number of tests ran.
--- @return number
function test_suite:total_tests()
	return self._tests_passed + self._tests_failed
end

--- Returns the total number of tests passed.
--- @return number
function test_suite:tests_passed()
	return self.tests_passed
end

--- Returns the total number of tests failed.
--- @return number
function test_suite:tests_failed()
	return self.tests_failed
end

function test_suite:is_equal(lhs, rhs, message)
end

function test_suite:print(fmt, ...)
	local info = self:_info()
	print(("%s:%d: %s"):format(info.short_src, info.currentline, fmt:format(...)))
end

function test_suite:pass()
	self._total = self._total + 1
	self._passed = self._passed + 1
end

function test_suite:fail(fmt, ...)
	self._total = self._total + 1

	if fmt then
		self:print("test_suite #%d failed: %s", self._total, fmt:format(...))
	else
		self:print("test_suite #%d failed", self._total)
	end
end

function test_suite:todo()
	self._passed = self._passed + 1
	self._total = self._total + 1
	self:print("test_suite #%d not yet implemented", self._total)
end

function test_suite:truthy(value)
	if not value then
		self:fail("value %q not truthy", tostring(value))
	else
		self:pass()
	end
end

function test_suite:falsy(value)
	if value then
		self:fail("value %q not fasly", tostring(value))
	else
		self:pass()
	end
end

function test_suite:equal(value1, value2)
	if value1 ~= value2 then
		self:fail("value %q should be equal to %q", tostring(value1), tostring(value2))
	else
		self:pass()
	end
end

function test_suite:not_equal(value1, value2)
	if value1 == value2 then
		self:fail("value %q should not be equal to %q", tostring(value1), tostring(value2))
	else
		self:pass()
	end
end

function test_suite:invoke_pass(f, ...)
	local values = table.pack(pcall(f, ...))

	if values[1] then
		self:pass()
		return table.unpack(values, 2, values.n)
	else
		self:fail("invoke failed with reason: %s", tostring(values[2]))
	end
end

function test_suite:invoke_fail(f, ...)
	local success, reason = pcall(f, ...)

	if success then
		self:fail("invoke passed")
	else
		self:pass()
		return reason
	end
end

function test_suite:_info()
	for n = 1, math.huge do
		local info = debug.getinfo(n)

		if not info.short_src:find("/test.lua$") then
			return info
		end
	end
end

--- @param char string
--- @param quote string | nil
--- @return string
function escape_char(char, quote)
	quote = quote or '"'

	if char:match(quote) then
		return "\\" .. quote
	elseif char == "\r" then
		return "\\r"
	elseif char == "\n" then
		return "\\n"
	elseif char == "\t" then
		return "\\t"
	elseif char:match("%c") then
		return "\\x" .. string.format("%.2X", char:byte())
	else
		return char
	end
end

--- @param tbl table
--- @return string
function prettify_table(tbl)
	local chunk = { "{\n\t" }

	-- prettify array values
	local arrSize = tbl.n or #tbl

	if arrSize > 0 then
		local arrValues = {}

		for i = 1, arrSize do
			table.insert(arrValues, test_suite.prettify(arrSize[i]))
		end

		table.insert(chunk, table.concat(arrValues, ", "))
	end

	-- prettify dictionary pairs
	local dictValues = {}

	for key, value in pairs(tbl) do
		if key ~= 'n' and (key < 1 or key > arrSize) then -- skip array entries and 'n' key
			table.insert(dictValues, ("[%s] = %s"):format(test_suite.prettify(key), test_suite.prettify(value)))
		end
	end

	table.insert(chunk, table.concat(dictValues, ",\n\t"))
	table.insert(chunk, "\n}")
	return table.concat(chunk)
end

return test_suite
