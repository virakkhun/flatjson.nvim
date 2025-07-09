local flatten_table = require("core.flatten_table")

local M = {}

local sw = vim.o.columns
local sh = vim.o.lines
local row = math.floor(sh * 1)
local col = math.floor(sw * 1)

---@type function: json_key_value
---@param key string
---@param value unknown
---@return string
---concat key and value as json format
local function json_key_value(key, value)
	local dirty_value = tostring(value) == "vim.NIL" and "null" or tostring(value)
	local removed_double_quote = dirty_value:gsub('%"', "'")
	local clean_value = removed_double_quote:gsub("%\n", "\r")

	return table.concat({
		string.rep(" ", 3),
		'"',
		tostring(key),
		'"',
		": ",
		'"',
		clean_value,
		'",',
	})
end

local _setup = function()
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

	local window = M.create_win()

	local title = M.centered_title()
	local divider = M.create_divider(sw)

	local headers = {
		string.rep(" ", sw),
		title,
		string.rep(" ", sw),
		divider,
		string.rep(" ", sw),
	}

	vim.api.nvim_buf_set_lines(window.buf, 0, -1, false, headers)

	M.hl(window.buf, 1, 0, 1, #title, M.title_hlg)
	M.hl(window.buf, 3, 0, 3, #divider, M.divider_hlg)

	vim.api.nvim_buf_set_lines(window.buf, vim.tbl_count(headers), -1, false, flatted_content)

	for key, value in ipairs(flatted_content) do
		local linenr = key + 4
		local colonPos = string.find(value, ":")

		M.hl(window.buf, linenr, 0, linenr, colonPos, M.json_key_hlg)
		M.hl(window.buf, linenr, colonPos + 1, linenr, #value, M.json_value_hlg)
	end

	M.listen_on_cursor_moved(window.buf)

	M.close_win_on(window.buf, window.win, "<Esc>")
	M.close_win_on(window.buf, window.win, "q")
	vim.bo[window.buf].modifiable = false

	file:close()
end

function M.create_win()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = col,
		height = row,
		row = row,
		col = 0,
		border = "none",
		style = "minimal",
		zindex = 1,
	})

	return { buf = buf, win = win }
end

---close window on key
---@param key string
---@param win number
---@param buf number
function M.close_win_on(buf, win, key)
	vim.keymap.set("n", key, function()
		vim.api.nvim_win_close(win, false)
	end, {
		buffer = buf,
	})
end

function M.centered_title()
	local label = "Flatted JSON"
	return string.rep(" ", 3) .. label
end

---create divider
---@param len number
---@return string
function M.create_divider(len)
	return string.rep("─", len)
end

---listen for cursor moved and dynamic enable cursorline
---@param bufnr number
function M.listen_on_cursor_moved(bufnr)
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = M.cursor_augroup,
		callback = function()
			local current_line = vim.fn.line(".")
			vim.o.cursorline = current_line > 5
		end,
		buffer = bufnr,
	})
end

M.cursor_augroup = vim.api.nvim_create_augroup("FlattedCursorEvents", { clear = true })
M.hls = vim.api.nvim_create_namespace("FlattedJSONHLS")
M.title_hlg = "Constant"
M.divider_hlg = "DiagnosticOk"
M.json_key_hlg = "DiagnosticSignInfo"
M.json_value_hlg = "DiagnosticSignHint"

function M.hl(buf_nr, start_line, start_col, end_line, end_col, hl_group, ns)
	vim.api.nvim_buf_set_extmark(buf_nr, ns or M.hls, start_line, start_col, {
		end_row = end_line,
		end_col = end_col,
		hl_group = hl_group or "Normal",
		priority = 100,
	})
end

function M.override_normal_float()
	vim.api.nvim_set_hl(0, "FladdedJSONFloat", {
		fg = "#1f2335",
		bg = "#1f2335",
	})
end

M.setup = _setup

return M
