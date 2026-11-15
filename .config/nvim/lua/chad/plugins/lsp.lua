-- Language servers. rust-analyzer is deliberately absent: rustaceanvim owns it
-- (see plugins/rust.lua). Per-server overrides live in after/lsp/<name>.lua.

-- Installed by mason (names are nvim-lspconfig config names)
local mason_servers = {
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "gopls",
  "graphql",
  "helm_ls",
  "html",
  "intelephense",
  "jsonls",
  "kotlin_language_server",
  "lua_ls",
  "prismals",
  "pyright",
  "sqlls",
  "taplo",
  "terraformls",
  "tflint",
  "tinymist",
  "ts_ls",
  "yamlls",
}

-- Expected on $PATH from elsewhere (brew / npm); silently skipped if missing
local external_servers = {
  "eslint", -- vscode-langservers-extracted (npm)
  "ruff", -- brew ruff (`ruff server`)
  "typos_lsp",
}

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = mason_servers,
      -- We call vim.lsp.enable() ourselves so that rust_analyzer is never
      -- auto-enabled alongside rustaceanvim.
      automatic_enable = false,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("chad.lsp").configure_clients()
      vim.lsp.enable(vim.list_extend(vim.deepcopy(mason_servers), external_servers))
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "BufReadPost",
    opts = {
      provider_selector = function()
        return { "lsp", "indent" }
      end,
    },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      {
        "zK",
        function()
          if not require("ufo").peekFoldedLinesUnderCursor() then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Peek fold / hover",
      },
    },
  },
}
