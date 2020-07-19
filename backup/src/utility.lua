local utility = { }

function utility.copy(src, _visited)
	if type(src) == "table" then
		_visited = _visited or {}

		if not _visited[src] then
			if not pcall(setmetatable, src, getmetatable(src)) then
				print("metatable may be inaccurate, __metatable is set")
			end

			local copy = {}
			_visited[src] = copy

			for key, value in pairs(src) do
				copy[utility.copy(key, _visited)] = utility.copy(value, _visited)
			end

			pcall(setmetatable, copy, getmetatable(src))
			src = copy
		else
			src = _visited[src]
		end
	end

	return src
end

return utility
