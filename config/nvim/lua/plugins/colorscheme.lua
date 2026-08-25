-- Rewrites the colorscheme assignment below so a pick from <leader>uC survives
-- a restart. Returns an error string when the line cannot be found, rather than
-- reporting success for a write that did not happen. The pattern is anchored to
-- a newline plus indentation so it cannot match a mention inside a comment.
local function persist(name)
  local path = vim.fn.stdpath("config") .. "/lua/plugins/colorscheme.lua"
  local file = io.open(path, "r")
  if not file then
    return "could not read " .. path
  end
  local contents = file:read("*a")
  file:close()

  local updated, count = contents:gsub('(\n%s+colorscheme%s*=%s*")[^"]*(")', "%1" .. name .. "%2", 1)
  if count == 0 then
    return "no colorscheme assignment found in " .. path
  end

  file = io.open(path, "w")
  if not file then
    return "could not write " .. path
  end
  file:write(updated)
  file:close()
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          colorschemes = {
            confirm = function(picker, item)
              picker:close()
              if not item then
                return
              end
              picker.preview.state.colorscheme = nil
              vim.schedule(function()
                vim.cmd("colorscheme " .. item.text)
                local err = persist(item.text)
                if err then
                  vim.notify(err, vim.log.levels.WARN, { title = "Colorscheme not persisted" })
                else
                  vim.notify("Saved " .. item.text, vim.log.levels.INFO, { title = "Colorscheme" })
                end
              end)
            end,
          },
        },
      },
    },
  },
}
