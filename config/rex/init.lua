-- >>> leaf >>>
-- Managed by `leaf rex install`; `leaf rex uninstall` removes it.
-- plugin: dbd96079ad70c4c6
dofile("/Users/jacebabin/.config/rex/plugins/leaf/init.lua").setup({ bin = { "/opt/homebrew/bin/leaf" } })
-- open: idle
-- <<< leaf <<<

-- smart-splits: the Rex half of nvim's smart-splits-backend-rex, loaded from lazy.nvim's checkout.
local ok, smart_splits = pcall(dofile, os.getenv("HOME") .. "/.local/share/nvim/lazy/smart-splits-backend-rex/rex/lua/smart-splits-rex/init.lua")
if ok then
  smart_splits.setup({ resize_amount = 5 })
  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    rex.bind("ctrl+" .. key, "smart_splits_focus", { direction = direction, key = "ctrl+" .. key })
    rex.bind("alt+" .. key, "smart_splits_resize", { direction = direction, key = "alt+" .. key })
  end
else
  rex.log("warn", "smart-splits: " .. tostring(smart_splits))
end

-- >>> rex-agent-resume
-- Starts the rex-agent-resume watcher whenever the server loads this file.
dofile("/Users/jacebabin/.local/share/rex-agent-resume/plugin.lua")
-- <<< rex-agent-resume
