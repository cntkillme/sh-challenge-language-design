package.path = "./src/?.lua;" .. package.path
local test_suite = require("test-suite");

--- Constants
local COLOR_PASS = "\27[32m"
local COLOR_FAIL = "\27[31m"
local COLOR_INFO = "\27[34m"
local COLOR_RESET = "\27[0m"

--- Test results
local tests_passed = 0
local tests_failed = 0
local tests_elapsed = 0

--- All the tests to run in the order specified.
local spec = {
	"test.test-suite-spec",
	"test.input-stream-spec",
	"test.output-stream-spec",
	"test.compiler.region-spec",
	"test.compiler.symbol-table-spec",
	"test.compiler.ast.abstract-node-spec",
	"test.compiler.ast.number-literal-spec",
	"test.compiler.ast.identifier-spec",
	"test.compiler.ast.unary-expression-spec",
	"test.compiler.ast.binary-expression-spec",
	"test.compiler.ast.call-expression-spec",
	"test.compiler.ast.variable-assignment-spec",
	"test.compiler.ast.function-definition-spec",
	"test.compiler.ast.variable-definition-spec",
	"test.compiler.ast.program-spec",
	"test.compiler.visitors.abstract-visitor-spec",
	"test.compiler.visitors.ast-printer-spec",
	"test.compiler.visitors.ast-constrainer-spec",
	"test.compiler.visitors.ast-codegen-spec",
	-- "test.compiler.parser-spec",
	-- "test.compiler-spec",
	-- "test.virtual-machine-spec"
}

--- @param ts test_suite
--- @param path string
--- @param elapsed number
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
			-- luacov: disable
			print(("%sTest failed%s at: %s\n%s"):format(
				COLOR_FAIL,
				COLOR_RESET,
				test.source,
				test.message
			))
			-- luacov: enable
		end
	end
end

-- Run tests
for _, path in ipairs(spec) do
	local ts = test_suite.new()
	local tester = require(path)
	local started = os.clock()
	tester(ts)
	local elapsed = os.clock() - started

	output_tests(ts, path, elapsed)
	tests_passed = tests_passed + ts:tests_passed()
	tests_failed = tests_failed + ts:tests_failed()
	tests_elapsed = tests_elapsed + elapsed
end

-- luacov: disable
if tests_failed > 0 then
	print(("%s*** %d failed tests! ***%s (%.3f s)"):format(COLOR_FAIL, tests_failed, COLOR_RESET, tests_elapsed))
	os.exit(1)
else
	print(("%s*** all tests passed! ***%s (%.3f s)"):format(COLOR_PASS, COLOR_RESET, tests_elapsed))
	os.exit(0)
end
