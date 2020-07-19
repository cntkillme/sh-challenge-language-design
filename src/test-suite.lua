--- Defines the environment for a set of tests.
--- @class test_suite
local test_suite = {}
test_suite.__index = test_suite

-- forward declarations
local get_source
local escape_char
local prettify_table

--- Creates a test_suite.
--- @return test_suite
function test_suite.new()
	return setmetatable({
		_tests = {},
		_passed = 0,
		_failed = 0
	}, test_suite)
end

--- Returns a readable string for values in the following manner:
---  - a `value` of type `nil`, `boolean`, and `number` results in `tostring(value)`,
---  - a `value` of type `string` results in a string wrapped in double quotes with all double quotes and binary data escaped,
---  - a `value` of type `table` results in a string representing the table with array values prettified followed by dictionary pairs prettified in alphabetical order,
---  - and any other `value` results in `<tostring(value)>`.
--- @param value any
--- @return string
function test_suite.prettify(value, _depth, _seen)
	local valueType = type(value)

	if valueType == "nil" or valueType == "boolean" or valueType == "number" then
		-- handle Lua 5.3 quirk
		if math.type(value) == "float" and value % 1 == 0 then
			value = math.floor(value)
		end

		return tostring(value)
	elseif valueType == "string" then -- escape quotes and binary data
		return '"' .. value:gsub('[%c"]', escape_char) .. '"'
	elseif valueType == "table" then
		return prettify_table(value, _depth, _seen)
	else
		return "<" .. tostring(value) .. ">"
	end
end

--- Returns the test results.
--- @return table
function test_suite:tests()
	return self._tests
end

--- Returns the total number of tests passed.
--- @return number
function test_suite:tests_passed()
	return self._passed
end

--- Returns the total number of tests failed.
--- @return number
function test_suite:tests_failed()
	return self._failed
end

--- Adds a passing test.
function test_suite:pass(message)
	self._passed = self._passed + 1
	table.insert(self._tests, { passed = true, message = message or "", source = get_source() })
end

--- Adds a failing test.
function test_suite:fail(message)
	self._failed = self._failed + 1
	table.insert(self._tests, { passed = false, message = message or "", source = get_source() })
end

--- Tests an expression and returns it.
--- @param cond any
--- @param message string | nil
--- @returns any
function test_suite:assert(cond, message)
	if cond then
		self:pass()
	else
		self:fail(message)
	end

	return cond
end

--- Tests for equality. Table equality is checked by comparing the prettified tables.
--- @param lhs any
--- @param rhs any
--- @return boolean
function test_suite:is_equal(lhs, rhs)
	if lhs == rhs or (type(lhs) == "table" and test_suite.prettify(lhs) == test_suite.prettify(rhs)) then
		if debug.getmetatable(lhs) == debug.getmetatable(rhs) then
			self:pass()
			return true
		else
			self:fail("expected same metatable")
		end
	else
		self:fail(("got: %s\nexpected: %s"):format(test_suite.prettify(lhs), test_suite.prettify(rhs)))
	end

	return false
end

--- Tests for inequality. Table inequality is checked by comparing the prettified tables.
--- @param lhs any
--- @param rhs any
--- @return boolean
function test_suite:not_equal(lhs, rhs)
	if lhs ~= rhs and (type(lhs) ~= "table" or test_suite.prettify(lhs) ~= test_suite.prettify(rhs)) then
		self:pass()
		return true
	end

	self:fail(("got: %s\nexpected: anything else"):format(test_suite.prettify(lhs)))
	return false
end

--- Tests for truthiness.
--- @param value any
--- @return boolean
function test_suite:is_truthy(value)
	if value then
		self:pass()
		return true
	end

	self:fail(("got: %s\nexpected: truthy value"):format(test_suite.prettify(value)))
	return false
end

--- Tests for falsyness.
--- @param value any
--- @return boolean
function test_suite:is_falsy(value)
	if not value then
		self:pass()
		return true
	end

	self:fail(("got: %s\nexpected: falsy value"):format(test_suite.prettify(value)))
	return false
end

--- Tests if a call completed without errors and returns the error or function's return values.
--- @param callable any
--- @return boolean
--- @return any
function test_suite:did_invoke_pass(callable, ...)
	local values = table.pack(pcall(callable, ...))

	if values[1] then
		self:pass()
	else
		self:fail(("invoke failed with error: %s"):format(tostring(values[2])))
	end

	return table.unpack(values, 1, values.n)
end

--- Tests if a call completed with errors and returns the error or function's return values.
--- @param callable any
--- @return boolean
--- @return any
function test_suite:did_invoke_fail(callable, ...)
	local values = table.pack(pcall(callable, ...))

	if not values[1] then
		self:pass()
	else
		self:fail(("expected invoke to fail!"):format(tostring(values[2])))
	end

	return table.unpack(values, 1, values.n)
end

-- luacov: disable

local info = debug.getinfo(1)

--- @return string
function get_source()
	for n = 1, math.huge do
		local info2 = debug.getinfo(n)

		if info2 and info.source ~= info2.source then
			return ("%s:%d"):format(info2.short_src, info2.currentline);
		elseif not info2 then
			break
		end
	end

	return "none"
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
--- @param depth integer
--- @param seen table
--- @return string
function prettify_table(tbl, depth, seen)
	depth = depth or 1
	seen = seen or {}

	if seen[tbl] then
		return "<" .. tostring(tbl) .. " cycle>"
	end

	seen[tbl] = true

	local chunk = { "{\n", ("\t"):rep(depth) }

	-- prettify array values
	local arrSize = tbl.n or #tbl

	if arrSize > 0 then
		local arrValues = {}

		for i = 1, arrSize do
			table.insert(arrValues, test_suite.prettify(tbl[i], depth + 1, seen))
		end

		table.insert(chunk, table.concat(arrValues, ", "))
		table.insert(chunk, ",\n" .. ("\t"):rep(depth))
	end

	-- prettify dictionary pairs
	local dictValues = {}

	for key, value in pairs(tbl) do
		if key ~= 'n' and (type(key) ~= "number" or key < 1 or key > arrSize) then -- skip array entries and 'n' key
			table.insert(dictValues, ("[%s] = %s"):format(
				test_suite.prettify(key, depth + 1, seen),
				test_suite.prettify(value, depth + 1, seen)
			))
		end
	end

	table.sort(dictValues)
	table.insert(chunk, table.concat(dictValues, ",\n" .. ("\t"):rep(depth)))
	table.insert(chunk, "\n" .. ("\t"):rep(depth - 1) .. "}")
	return table.concat(chunk)
end

-- luacov: enable

return test_suite
