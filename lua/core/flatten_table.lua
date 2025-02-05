local M = {}

---@type function: flatten_table
---@param data table: a nested table
---@param prefix string: default to '.'
---a function to flat the table into an Array like table
---```json
---{
---  "key.key.key": "value"
---}
---```
local function flatten_table(data, prefix)
	local result = {}
	local p = prefix or "."
	local maybe_array = {}

	for k, v in pairs(data) do
		if type(v) == "table" then
			local nested_result = flatten_table(v, p)
			for nested_k, nested_v in pairs(nested_result) do
				if nested_k == nested_v then
					table.insert(maybe_array, nested_v)
					result[k] = "[" .. table.concat(maybe_array, ", ") .. "]"
				else
					result[k .. p .. nested_k] = nested_v
				end
			end
		else
			result[k] = v
		end
	end
	return result
end

M.flat = flatten_table

return M
