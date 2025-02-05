local M = {}

---@type function: open_win
---@class ActiveWin
---@field buf number
---@field win number
---@return ActiveWin
---a function to create a scratch buffer and open window
local open_win = function()
	local width = vim.o.columns
	local height = vim.o.lines
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		border = "rounded",
		focusable = true,
		relative = "win",
		width = width,
		height = height,
		row = 0,
		col = 0,
	})

	return { buf = buf, win = win }
end

M.open = open_win

return M
