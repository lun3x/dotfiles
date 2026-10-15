return {
	{
		"NicolasGB/jj.nvim",
		version = "*",
		config = function()
			require("jj").setup({})
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		end,
	},
	{
		"sindrets/diffview.nvim",
	},
}
