-- Git: gitsigns for gutter hunk indicators and inline staging, neogit for
-- the magit-style UI (replaces vim-fugitive).
return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        opts = {},
    },
}
