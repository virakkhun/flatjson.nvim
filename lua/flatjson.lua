local M = {}

-- a function flatten table
local function flattenTable(table, prefix)
	local flattened = {}
	prefix = prefix or "" -- Handle cases where no prefix is provided

	for k, v in pairs(table) do
		local newKey = prefix .. k
		if type(v) == "table" then
			-- Recursively flatten nested tables
			local nestedFlattened = flattenTable(v, newKey .. ".")
			for nk, nv in pairs(nestedFlattened) do
				flattened[nk] = nv
			end
		else
			flattened[newKey] = v
		end
	end
	return flattened
end

local _setup = function()
	local treesitter = vim.treesitter

	local present_keymap = function(mode, key, callback, bufnr)
		vim.keymap.set(mode, key, callback, {
			buffer = bufnr,
		})
	end

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

	local cur_bufnr = vim.api.nvim_get_current_buf()
	local cur_buf_name = vim.fn.bufname(cur_bufnr)
	local is_no_json_file = vim.bo.filetype ~= "json"

	if is_no_json_file then
		print("Only work with json...")
	else
		local cmds = { "sh", "lua/executor.sh", cur_buf_name }
		local cmd = table.concat(cmds, " ")
		local handle = io.popen(cmd, "r")
		local content = {}

		if handle ~= nil then
			local result = handle:lines()
			for _ in result do
				table.insert(content, _)
			end

			local window = open_win()

			vim.api.nvim_buf_set_lines(window.buf, 0, -1, false, content)
			treesitter.start(window.buf, "json")

			present_keymap("n", "q", function()
				vim.api.nvim_buf_delete(window.buf, { force = true })
			end, window.buf)

			handle:close()
		else
			print("Something went wrong...")
		end
	end
end

M.setup = _setup

return M
