-- Catppuccin colorscheme. priority=1000 forces it to load before any other
-- plugin so their highlight groups pick up the theme on first paint.
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            integrations = {
                neotree = true,
                gitsigns = true,
                treesitter = true,
            },
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
