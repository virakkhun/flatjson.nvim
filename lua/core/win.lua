local M = {}

local set_lines = vim.api.nvim_buf_set_lines
local open_window = vim.api.nvim_open_win
local start_highlight = vim.treesitter.start
local autocmd = vim.api.nvim_create_autocmd
local win_close = vim.api.nvim_win_close

local sw = vim.o.columns
local sh = vim.o.lines

local bw = math.floor(sw * 0.8)
local bh = math.floor(sh * 0.8)
local brow = math.floor((sh - bh) * 0.5) - 1
local bcol = math.floor((sw - bw) * 0.5)

local body_w = math.floor(bw * 0.8)
local body_h = math.floor(bh * 0.7)
local body_col = math.floor((sw - body_w) * 0.5)

local function scratch_buffer()
	return vim.api.nvim_create_buf(false, true)
end

local window = {
	---@type vim.api.keyset.win_config
	background = {
		relative = "editor",
		width = bw,
		height = bh,
		row = brow,
		col = bcol,
		border = "single",
		style = "minimal",
		zindex = 1,
	},
	---@type vim.api.keyset.win_config
	header = {
		relative = "editor",
		width = bw,
		height = 1,
		row = math.floor(sh * 0.1),
		col = body_col,
		border = "rounded",
		style = "minimal",
		zindex = 2,
	},
	---@type vim.api.keyset.win_config
	body = {
		relative = "editor",
		width = body_w,
		height = body_h,
		row = math.floor(sh * 0.2),
		col = body_col,
		border = "rounded",
		style = "minimal",
		zindex = 2,
	},
	---@type vim.api.keyset.win_config
	footer = {
		relative = "editor",
		width = bw,
		height = 1,
		row = math.floor(sh * 0.85),
		col = bcol,
		border = "rounded",
		style = "minimal",
	},
}

---@type function: key_mapping
---@param mode string
---@param key string
---@param callback function
---@param bufnr number
local function key_mapping(mode, key, callback, bufnr)
	vim.keymap.set(mode, key, callback, {
		buffer = bufnr,
	})
end

local function background_component()
	local buf = scratch_buffer()
	local win = open_window(buf, false, window.background)
	return { bufnr = buf, win = win }
end

local function header_component()
	local header_buf = scratch_buffer()
	local win = open_window(header_buf, false, window.header)

	local label = "Flatted JSON"
	local padding = math.floor((body_w - #label) / 2)
	local text = string.rep(" ", padding) .. label
	set_lines(header_buf, 0, -1, false, { text })

	return { bufnr = header_buf, win = win }
end

local function footer_component()
	local footer_buf = scratch_buffer()
	local win = open_window(footer_buf, false, window.footer)

	local footer_text = "  ` q `: To quit the window"
	set_lines(footer_buf, 0, -1, false, { footer_text })
	start_highlight(footer_buf, "markdown")

	return { bufnr = footer_buf, win = win }
end

local function body_component()
	local buf = scratch_buffer()
	local win = open_window(buf, true, window.body)
	return { bufnr = buf, win = win }
end

---@type function: open_win
---@class ActiveWin
---@field buf number
---@field win number
---@return ActiveWin
---a function to create a scratch buffer and open window
function M.open()
	local background = background_component()
	local body = body_component()
	local header = header_component()
	local footer = footer_component()

	key_mapping("n", "q", function()
		win_close(body.win, false)
	end, body.bufnr)

	autocmd("BufLeave", {
		buffer = body.bufnr,
		callback = function()
			win_close(header.win, false)
			win_close(background.win, false)
			win_close(footer.win, false)
		end,
		desc = "Close others window when body is closed",
	})

	return { buf = body.bufnr, win = body.win }
end

return M
