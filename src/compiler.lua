local parser = require("compiler.parser")
local ast_codegen = require("compiler.visitors.ast-codegen")
local ast_constrainer = require("compiler.visitors.ast-constrainer")

-- Constants
local COLOR_PASS = "\27[32m"
local COLOR_FAIL = "\27[31m"
local COLOR_RESET = "\27[0m"

--- @param diagnostics diagnostic[]
--- @param path string
local function print_diagnostics(diagnostics, path)
	for _, diagnostic in ipairs(diagnostics) do
		print("%s:%d:%d: %s%s%s"):format(
			path,
			diagnostic.origin.line,
			diagnostic.origin.column,
			COLOR_FAIL,
			diagnostic.message,
			COLOR_RESET
		)
	end
end

--- Interface to the entire compilation process.
--- @param istream input_stream
--- @param ostream output_stream
return function(istream, ostream)
	local ast = parser.new(istream):parse()
	local astConstrainer = ast_constrainer.new()
	local astCodegen = ast_codegen.new()
	local diagnosticsList = {}

	if #parser:diagnostics() > 0 then
		-- luacov: disable
		table.insert(diagnosticsList, parser:diagnostics())
		-- luacov: enable
	end

	ast:accept(astConstrainer)

	if #astConstrainer:diagnostics() > 0 then
		-- luacov: disable
		table.insert(diagnosticsList, astConstrainer:diagnostics())
		-- luacov: enable
	end

	ast:accept(astCodegen)

	if #astCodegen:diagnostics() > 0 then
		-- luacov: disable
		table.insert(diagnosticsList, astCodegen:diagnostics())
		-- luacov: enable
	end

	if #diagnosticsList == 0 then
		ostream:write(astCodegen:content())
		ostream:flush()
		print(("%s: %scompilation succeeded!%s"):format(istream:path(), COLOR_PASS, COLOR_RESET))
	else
		-- luacov: disable
		print(("%s: %scompilation failed!%s"):format(istream:path(), COLOR_FAIL, COLOR_RESET))

		for _, diagnostics in ipairs(diagnosticsList) do
			print_diagnostics(diagnostics, istream:path())
		end
		-- luacov: enable
	end
end
