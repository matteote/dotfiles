-- Seamless pane navigation between nvim splits and tmux panes via Alt+arrows.
-- Tmux's matching bindings (in dot_config/tmux/tmux.conf.tmpl) detect nvim and
-- forward the key here when nvim owns the pane; otherwise tmux moves itself.
return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
    },
    keys = {
        -- `t` covers toggleterm/embedded terminals (claude CLI etc.) where
        -- Alt+arrows would otherwise pass through to the running program.
        { "<M-Left>",  "<cmd>TmuxNavigateLeft<cr>",  mode = { "n", "i", "t" }, desc = "Navigate left (nvim/tmux)" },
        { "<M-Down>",  "<cmd>TmuxNavigateDown<cr>",  mode = { "n", "i", "t" }, desc = "Navigate down (nvim/tmux)" },
        { "<M-Up>",    "<cmd>TmuxNavigateUp<cr>",    mode = { "n", "i", "t" }, desc = "Navigate up (nvim/tmux)" },
        { "<M-Right>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "i", "t" }, desc = "Navigate right (nvim/tmux)" },
    },
    init = function()
        -- Disable the plugin's default Ctrl+h/j/k/l mappings; we wire Alt+arrows above.
        vim.g.tmux_navigator_no_mappings = 1
    end,
}
