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
  "intelephense",
  "yamlls",
  "gopls",
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
        handlers = {
          function(server_name)
            if server_name == "tsserver" then
              server_name = "ts_ls"
            end
          end,
        },
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
          require("ufo").setup({
            provider_selector = function()
              return { "lsp", "indent" }
            end,
          })
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
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      null_ls.setup({
        sources = {
          --actions
          actions.eslint_d,

          -- formatting
          formatting.gofumpt,
          formatting.goimports_reviser,
          formatting.golines,
          formatting.clang_format,
          formatting.prettier,
          formatting.stylua,
          formatting.terraform_fmt,
          formatting.rustfmt,
          formatting.stylelint,
          formatting.tidy,
          diagnostics.sqlfluff,
          formatting.taplo,

          -- diagnostics
          diagnostics.clang_check,
          diagnostics.typos,
          diagnostics.eslint,
          diagnostics.flake8,
          diagnostics.cppcheck,
          diagnostics.terraform_validate,
          diagnostics.yamllint,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({
              group = augroup,
              buffer = bufnr,
            })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },
}
