-- Editor-wide vim.opt settings. New global options go here.

-- Mouse in all modes (adds command-line and prompt support over the default `nvi`).
vim.opt.mouse = "a"

-- Indentation: 4 spaces, no tabs.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Display.
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Search & substitute.
vim.opt.ignorecase = true
vim.opt.gdefault = true

-- Editing behaviour.
vim.opt.whichwrap:append("<,>,[,]")
vim.opt.selection = "exclusive"
vim.opt.mousemodel = "popup"

-- Bell.
vim.opt.errorbells = false
vim.opt.visualbell = true
