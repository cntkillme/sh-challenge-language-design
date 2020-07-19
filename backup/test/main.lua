package.path = "./test/?.lua;./src/?.lua;" .. package.path

if _VERSION == "Lua 5.1" then
	function table.pack(...)
		return {n = select('#', ...), ...}
	end

	table.unpack = _G.unpack
end

local tests = {
	-- pre-existing tests
	"test-utility",
	"test-input-stream",
	"test-output-stream",
	"compiler.ast.test-abstract-node",
	"compiler.ast.test-program",
	"compiler.ast.test-variable-definition",
	"compiler.ast.test-variable-assignment",
	"compiler.ast.test-function-call",
	"compiler.ast.test-binary-expression",
	"compiler.ast.test-unary-expression",
	"compiler.ast.test-input-argument",
	"compiler.ast.test-identifier",
	"compiler.ast.test-number",
	"compiler.visitors.test-abstract-visitor",
	"compiler.visitors.test-ast-printer",
	"compiler.visitors.test-ast-interpreter",
	"compiler.visitors.test-ast-codegen",

	-- implementation tests
	"compiler.test-parser",
	"interpreter.test-virtual-machine"
}

local test = require("test")
local total = 0
local passed = 0
local duration = 0

print("****** TESTING BEGIN ******\n")

for idx, path in ipairs(tests) do
	print(("*** TEST %d: %s ***"):format(idx, path))
	local context = test.new()
	local began = os.clock()
	require(path)(context)
	local elapsed = 1000 * (os.clock() - began)
	total = total + context:total()
	passed = passed + context:passed()
	duration = duration + elapsed
	print(("*** RESULTS: %d failed, %d passed, %d total; %.5f ms ***\n"):format(context:failed(), context:passed(),
		context:total(), elapsed))
end

print(("****** TOTALS: %d failed, %d passed, %d total; %.5f ms ******"):format(total - passed, passed, total,
	duration))

if passed ~= total then
	error(total - passed .. " tests failed!", 0)
end
