-- File explorer (replaces NERDTree). `<leader>t` mirrors the vimrc binding.
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>t", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        filesystem = {
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
    },
}
