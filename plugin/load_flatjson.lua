vim.api.nvim_create_user_command("FlatJson", function()
	package.loaded["flatjson"] = nil
	require("flatjson").setup()
end, {})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.json",
	callback = function()
		vim.keymap.set("n", "<leader>f", "<cmd>FlatJson<cr>")
	end,
})
