-- luacov: disable

package.path = "./src/?.lua;" .. package.path

--- All the tests to run in the order specified.
local spec = {
	"test.test-suite-spec",
	"test.input-stream-spec",
	"test.output-stream-spec",
	"test.compiler.position-spec",
	"test.compiler.symbol-table-spec"
}

local test_suite = require("test-suite");
local tests_passed = 0
local tests_failed = 0
local tests_elapsed = 0

local COLOR_PASS = "\27[32m"
local COLOR_FAIL = "\27[31m"
local COLOR_INFO = "\27[34m"
local COLOR_RESET = "\27[0m"

local function output_tests(ts, path, elapsed)
	print(("%s%s%s (%s%d/%d passed%s, %.3f s)"):format(
		COLOR_INFO,
		path,
		COLOR_RESET,
		ts:tests_failed() > 0 and COLOR_FAIL or COLOR_PASS,
		ts:tests_passed(),
		ts:tests_passed() + ts:tests_failed(),
		COLOR_RESET,
		elapsed
	))

	for _, test in ipairs(ts:tests()) do
		if not test.passed then
			print(("%sTest failed%s at: %s\n%s"):format(
				COLOR_FAIL,
				COLOR_RESET,
				test.source,
				test.message
			))
		end
	end
end

-- Run tests.
for _, path in ipairs(spec) do
	local ts = test_suite.new()
	local tester = require(path)
	local started = os.clock()
	local mode = tester(ts)
	local elapsed = os.clock() - started

	if mode ~= "todo" then
		output_tests(ts, path, elapsed)
		tests_passed = tests_passed + ts:tests_passed()
		tests_failed = tests_failed + ts:tests_failed()
		tests_elapsed = tests_elapsed + elapsed

		if mode == "abort" then
			if ts:tests_failed() > 0 then
				break
			end
		elseif mode ~= "continue" then
			error("bad sink mode for test " .. path)
		end
	end
end

if tests_failed > 0 then
	print(COLOR_FAIL .. "*** " .. tests_failed .. " failed tests! ***" .. COLOR_RESET)
	os.exit(1)
else
	print(COLOR_PASS .. "*** all tests passed! ***" .. COLOR_RESET)
	os.exit(0)
end

-- luacov: enable
