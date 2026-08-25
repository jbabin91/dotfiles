-- Directional navigation and resizing that crosses the nvim/multiplexer
-- boundary: the same keys move between nvim splits and tmux (or zellij) panes.
-- Must not be lazy-loaded, since the tmux side keys off the @pane-is-vim pane
-- variable that this plugin sets when it loads.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    -- LazyVim's <C-Up/Down/Left/Right> resize maps stay; these are the hjkl pair.
    default_amount = 5,
  },
  keys = {
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left window" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to lower window" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to upper window" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right window" },
    { "<M-h>", function() require("smart-splits").resize_left() end, desc = "Resize window left" },
    { "<M-j>", function() require("smart-splits").resize_down() end, desc = "Resize window down" },
    { "<M-k>", function() require("smart-splits").resize_up() end, desc = "Resize window up" },
    { "<M-l>", function() require("smart-splits").resize_right() end, desc = "Resize window right" },
  },
}
