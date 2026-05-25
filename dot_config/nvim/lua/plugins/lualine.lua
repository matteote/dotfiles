-- Statusline (replaces vim-airline). Branch is shown in section_b by default.
return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- `catppuccin-nvim` follows whatever flavour catppuccin is configured
        -- with (mocha here); plain `catppuccin` is not a theme name the
        -- plugin ships, only `catppuccin-<flavour>` and `catppuccin-nvim`.
        options = { theme = "catppuccin-nvim", globalstatus = false },
    },
}
