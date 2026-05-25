-- Treesitter-driven syntax highlighting and indentation, plus rainbow-delimiters
-- (replaces the old vim-rainbow plugin). Parsers in `ensure_installed` are
-- compiled on first sync.
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "yaml", "markdown" },
            highlight = { enable = true },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
}
