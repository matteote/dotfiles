-- Commenter (replaces nerdcommenter). Default bindings: `gcc` line,
-- `gc{motion}` operator, `gc` in visual mode.
return {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
}
