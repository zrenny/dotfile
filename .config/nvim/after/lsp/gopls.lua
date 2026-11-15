-- These options were previously at the top level of `settings`, where gopls
-- ignores them; they belong under `settings.gopls`.
---@type vim.lsp.Config
return {
  settings = {
    gopls = {
      buildFlags = { "-tags=debug dev" },
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
}
