vim.api.nvim_create_user_command("FlatJson", function(args)
	package.loaded["flatjson"] = nil
	local arg = args.args == "" and "default" or args.args
	require("flatjson").setup(arg)
end, {
	nargs = "*",
	complete = function()
		return { "key", "default" }
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.json",
	callback = function()
		vim.keymap.set("n", "<leader>f", "<cmd>FlatJson<cr>")
	end,
})
