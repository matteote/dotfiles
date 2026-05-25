-- Global keymaps ported from the old vimrc. Plugin-specific bindings live in
-- their plugin specs (so the plugin only loads when its key fires).
-- Leader stays as the vim default `\` — set vim.g.mapleader here to change it.

local map = vim.keymap.set

-- F1 -> Esc (avoid accidental F1 opening :help on keyboards where F1 sits next to Esc).
map({ "n", "i" }, "<F1>", "<Esc>")

-- Backspace in visual deletes the selection.
map("v", "<BS>", "d")

-- Leader bindings.
map("n", "<leader>a", "ggVG",                 { desc = "Select all" })
map("n", "<leader>\\", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>`", "gv",                   { desc = "Re-select last visual block" })
map("n", "<leader>h", "*<C-O>",               { desc = "Highlight word at cursor" })
map("n", "<leader>i", "<cmd>set list!<cr>",   { desc = "Toggle invisibles" })
map("n", "<leader>n", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative line numbers" })

-- Re-select visual after indent so `<` / `>` can be chained.
map("v", "<", "<gv")
map("v", ">", ">gv")
