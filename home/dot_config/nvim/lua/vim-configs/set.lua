local o = vim.opt

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

o.guicursor = ""

o.nu = true
o.relativenumber = true

o.autoindent = true
o.smartindent = false

o.expandtab = false
o.softtabstop = 4
o.shiftwidth = 4
o.tabstop = 4

o.wrap = false

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("FiletypeWrap", { clear = true }),
	callback = function()
		vim.wo.wrap = vim.bo.filetype == "markdown" or vim.bo.filetype == "text"
	end,
})

o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

o.termguicolors = true

-- Show spaces
-- vim.opt.list = true
-- vim.opt.listchars = "tab:→ ,space:·"

o.scrolloff = 8
o.signcolumn = "yes"
o.isfname:append("@-@")

o.updatetime = 1000
o.timeoutlen = 300

o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	command = "checktime",
})

o.cursorline = true

-- Render the current line's diagnostics as virtual lines beneath it
vim.diagnostic.config({
	virtual_lines = { current_line = true },
})
