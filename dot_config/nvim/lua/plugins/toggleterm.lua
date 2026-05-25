-- Terminal toggler for a side-panel coding agent CLI. The command is whatever
-- $AGENT_CMD resolves to in the shell that launched nvim (set by zsh's
-- .zshenv, defaulting to `claude`), so swapping harnesses is a zsh-level
-- change — no nvim config edits needed.
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        -- Same key (Alt+c) is bound in tmux (see tmux.conf.tmpl) so the agent
        -- panel feels identical whether or not nvim is the foreground process.
        { "<M-c>", "<cmd>lua _AGENT_TOGGLE()<cr>", mode = { "n", "i", "t" }, desc = "Toggle agent CLI side panel" },
    },
    opts = {
        direction = "vertical",
        size = function(term)
            if term.direction == "vertical" then
                return math.floor(vim.o.columns * 0.4)
            end
            return 20
        end,
        start_in_insert = true,
        persist_mode = true,
        shade_terminals = false,
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
        local Terminal = require("toggleterm.terminal").Terminal
        local agent_term = Terminal:new({
            cmd = vim.env.AGENT_CMD or "claude",
            direction = "vertical",
            hidden = true,
        })
        function _G._AGENT_TOGGLE()
            agent_term:toggle()
        end
    end,
}
