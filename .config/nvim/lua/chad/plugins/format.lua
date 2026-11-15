-- Formatting (conform.nvim) and linting (nvim-lint). Replaces none-ls, which
-- never formatted Rust on save because no none-ls source attached to .rs files.
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        -- rust-analyzer runs the toolchain's rustfmt with the crate's edition
        -- and rustfmt.toml; standalone rustfmt is the fallback.
        rust = { "rustfmt", lsp_format = "prefer" },
        go = { "gofumpt", "goimports-reviser", "golines" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        css = { "prettier", "stylelint" },
        scss = { "prettier", "stylelint" },
        less = { "prettier", "stylelint" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        html = { "prettier" },
        xml = { "tidy" },
        toml = { "taplo" },
      },
      formatters = {
        -- conform has no built-in tidy; same args none-ls used
        tidy = {
          command = "tidy",
          args = { "--tidy-mark", "no", "-quiet", "-indent", "-wrap", "-", "-xml" },
          stdin = true,
          exit_codes = { 0, 1 },
        },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(buf)
        if vim.b[buf].disable_autoformat or vim.g.disable_autoformat then
          return
        end
        -- Only auto-format filetypes listed above (like the old none-ls setup);
        -- <leader>f still formats anything via LSP.
        if not require("conform").formatters_by_ft[vim.bo[buf].filetype] then
          return
        end
        -- rust-analyzer can be slow on big files right after startup
        return { timeout_ms = vim.bo[buf].filetype == "rust" and 3000 or 1000 }
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("FormatToggle", function(opts)
        local scope = opts.bang and vim.b or vim.g
        scope.disable_autoformat = not scope.disable_autoformat
        vim.notify("Format on save " .. (scope.disable_autoformat and "disabled" or "enabled") .. (opts.bang and " (buffer)" or ""))
      end, { bang = true, desc = "Toggle format on save (! = buffer only)" })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sql = { "sqlfluff" },
        c = { "cppcheck" },
        cpp = { "cppcheck" },
        yaml = { "yamllint" },
        terraform = { "terraform_validate" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("chad_lint", { clear = true }),
        callback = function()
          -- ignore_errors: don't nag when a linter binary isn't installed
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
      lint.try_lint(nil, { ignore_errors = true })
    end,
  },
}
