vim.api.nvim_create_user_command("FlatJSON", function()
	package.loaded["flatjson"] = nil
	require("flatjson").setup()
end, {})
