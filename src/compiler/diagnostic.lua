--- An indication of a compile-time error.
--- @class diagnostic
local diagnostic = {}
diagnostic.__index = diagnostic

--- Creates a diagnostic.
--- @param message string
--- @param origin position
--- @return diagnostic
function diagnostic.new(message, origin)
	return {
		message = message,
		origin = origin
	}
end

return diagnostic
