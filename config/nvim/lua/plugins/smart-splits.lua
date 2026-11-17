-- Directional navigation and resizing that crosses the nvim/multiplexer
-- boundary: the same keys move between nvim splits and tmux, zellij or Rex panes.
-- Must not be lazy-loaded, since the tmux side keys off the @pane-is-vim pane
-- variable that the tmux backend sets when it loads.
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux", opts = {} },
    { "smart-splits-nvim/backend-zellij-lua", main = "smart-splits-backend-zellij-lua", opts = {} },
    -- Its rex/ directory is also the Rex-side module ~/.config/rex/init.lua loads.
    { "rawnly/smart-splits-backend-rex", opts = {} },
  },
  opts = {
    -- LazyVim's <C-Up/Down/Left/Right> resize maps stay; these are the hjkl pair.
    resize = { amount = 5 },
    mux = {
      -- Innermost multiplexer first: a tmux or zellij pane inside Rex detects Rex too.
      backend = { "smart-splits-backend-tmux", "smart-splits-backend-zellij-lua", "smart-splits-backend-rex" },
      warn_if_unusable = false,
    },
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
