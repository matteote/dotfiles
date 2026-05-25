-- Multi-cursor support. Lazy-loaded on first interactive use; the plugin
-- registers its own <C-n> / <C-Up> / <C-Down> bindings on load.
return {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
}
