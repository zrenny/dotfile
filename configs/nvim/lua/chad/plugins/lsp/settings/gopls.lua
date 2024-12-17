return {
  settings = {
    completeUnimported = true,
    usePlaceholders = true,
    analyses = {
      unusedparams = true,
    },
    gopls = {
      buildFlags = { "-tags=debug dev" },
    },
  },
}
