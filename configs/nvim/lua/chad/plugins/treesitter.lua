return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "t32" }, -- List of parsers to ignore installing
        autopairs = {
          enable = true,
        },
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = { "" }, -- list of language that will be disabled
          additional_vim_regex_highlighting = true,
        },
        indent = { enable = true, disable = { "" } },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        playground = {
          enable = true
        }
      })
    end,
  },
  {
    "nvim-treesitter/playground",
    cmd = { "TSInstall" },
    build = ":TSInstall query",
  }
}
