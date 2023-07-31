local servers = {
  "jsonls",
  "lua_ls",
  "rust_analyzer",
  "clangd",
  "cmake",
  "cssls",
  "dockerls",
  "docker_compose_language_service",
  "eslint",
  "graphql",
  "html",
  "helm_ls",
  "tsserver",
  "kotlin_language_server",
  "prismals",
  "pyright",
  "sqlls",
  "taplo",
  "terraformls",
  "tflint",
  "yamlls",
}

return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    lazy = false,
    priority = 1000,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        config = function()
          require("ufo").setup()
        end,
      },
    },
    lazy = false,
    priority = 900,
    config = function()
      local opts = {}
      local config = require("lspconfig")

      for _, ls in ipairs(servers) do
        opts = {
          on_attach = require("chad.plugins.lsp.handlers").on_attach,
          capabilities = require("chad.plugins.lsp.handlers").capabilities,
        }

        ls = vim.split(ls, "@")[1]
        local ok, config_opts = pcall(require, "chad.plugins.lsp.settings." .. ls)

        if ok then
          opts = vim.tbl_deep_extend("force", config_opts, opts)
        end

        config[ls].setup(opts)
      end
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local actions = null_ls.builtins.code_actions

      null_ls.setup({
        sources = {
          --actions

          -- formatting
          formatting.prettier,
          formatting.stylua,
          formatting.terraform_fmt,
          formatting.rustfmt,
          formatting.stylelint,
          formatting.tidy,
          diagnostics.sqlfluff,
          formatting.taplo,

          -- diagnostics
          diagnostics.typos,
          diagnostics.eslint,
          diagnostics.flake8,
          diagnostics.cppcheck,
          diagnostics.terraform_validate,
          diagnostics.yamllint,
        },
      })
    end,
  },
}
