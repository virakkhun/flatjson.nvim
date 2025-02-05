local win = require("core.win")
local flatten_table = require("core.flatten_table")

local M = {}

---@type function: key_mapping
---@param mode string
---@param key string
---@param callback function
---@param bufnr number
local key_mapping = function(mode, key, callback, bufnr)
	vim.keymap.set(mode, key, callback, {
		buffer = bufnr,
	})
end

---@type function: json_key_value
---@param key string
---@param value unknown
---@return string
---concat key and value as json format
local function json_key_value(key, value)
	return table.concat({
		'  "',
		tostring(key),
		'"',
		": ",
		'"',
		tostring(value) == "vim.NIL" and "null" or tostring(value),
		'",',
	})
end

local _setup = function()
	local treesitter = vim.treesitter

	local cur_bufnr = vim.api.nvim_get_current_buf()
	local cur_buf_name = vim.fn.bufname(cur_bufnr)
	local is_not_json_file = vim.bo.filetype ~= "json"

	if is_not_json_file then
		vim.notify("Only work with json...✨", vim.log.levels.INFO, {})
		return
	end

	local file = io.open(cur_buf_name, "r")

	if file == nil then
		vim.notify("Unable to read file at " .. cur_buf_name, vim.log.levels.ERROR, {})
		return
	end

	local lines = {}
	local result = file:lines()

	for line in result do
		table.insert(lines, line)
	end

	local stringify = table.concat(lines)
	local decoded_table = vim.json.decode(stringify)
	local flatted_table = flatten_table.flat(decoded_table, ".")
	local flatted_content = {}

	for key, value in pairs(flatted_table) do
		local v = json_key_value(key, value)
		table.insert(flatted_content, v)
	end

	local window = win.open()

	table.insert(flatted_content, 1, "{")
	table.insert(flatted_content, "}")

	vim.api.nvim_buf_set_lines(window.buf, 0, -1, false, flatted_content)

	treesitter.start(window.buf, "json")

	key_mapping("n", "q", function()
		vim.api.nvim_buf_delete(window.buf, { force = true })
	end, window.buf)

	file:close()
end

M.setup = _setup

return M
