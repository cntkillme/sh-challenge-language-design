local parser = require("compiler.parser")
local ast_codegen = require("compiler.visitors.ast-codegen")
local ast_constrainer = require("compiler.visitors.ast-constrainer")

--- Interface to the entire compilation process.
--- TODO: pretty-print all diagnostics (requires exposing various properties of input_stream and output_stream).
--- @param istream input_stream
--- @param ostream output_stream
return function(istream, ostream)
	local ast = parser.new(istream):parse()
	local astConstrainer = ast_constrainer.new()
	local astCodegen = ast_codegen.new()

	ast:accept(astConstrainer)

	if #astConstrainer:diagnostics() > 0 then
		-- luacov: disable
		local diagnostic = astConstrainer:diagnostics()[1]

		istream:error(
			diagnostic.message,
			diagnostic.node and diagnostic.node.region and diagnostic.node.region.first_line or 1,
			diagnostic.node and diagnostic.node.region and diagnostic.node.region.first_column or 1
		)
		-- luacov: enable
	end

	ast:accept(astCodegen)

	if #astCodegen:diagnostics() > 0 then
		-- luacov: disable
		local diagnostic = astCodegen:diagnostics()[1]
		istream:error(diagnostic.message, 0, 0)
		-- luacov: enable
	end

	ostream:write(astCodegen:content())
	istream:close()
	ostream:close()
	print("compilation success")
end
