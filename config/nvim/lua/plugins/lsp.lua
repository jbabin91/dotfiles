return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
              local bufname = vim.api.nvim_buf_get_name(result.uri and vim.uri_to_bufnr(result.uri) or 0)
              if string.match(bufname, '%.env') then
                -- Don't publish diagnostics for .env files
                return
              end
              -- Call the default handler for non-.env files
              vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
            end,
          },
        },
      },
    },
  },
}
