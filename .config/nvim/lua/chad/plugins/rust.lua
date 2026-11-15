-- Rust: rustaceanvim (rust-analyzer + cargo integration + debugging),
-- crates.nvim (Cargo.toml), RustOwl (ownership/lifetime visualisation).
-- Buffer keymaps for Rust live in after/ftplugin/rust.lua.

-- Prefer the rustup-managed rust-analyzer so it always matches the project's
-- toolchain. Mason prepends its bin dir to $PATH, so a leftover mason
-- rust-analyzer would otherwise shadow it.
local function rust_analyzer_cmd()
  local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.env.HOME, ".cargo")
  local rustup_ra = vim.fs.joinpath(cargo_home, "bin", "rust-analyzer")
  if vim.fn.executable(rustup_ra) == 1 then
    return { rustup_ra }
  end
  return { "rust-analyzer" }
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- it's a filetype plugin; already lazy
    init = function()
      ---@type rustaceanvim.Opts
      vim.g.rustaceanvim = {
        tools = {
          -- Run tests in the background and surface failures as diagnostics
          test_executor = "background",
          code_actions = { ui_select_fallback = true },
        },
        server = {
          cmd = rust_analyzer_cmd,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allTargets = true,
                buildScripts = { enable = true },
                -- Separate target dir so `cargo build` in a terminal doesn't
                -- block on rust-analyzer's check (and vice versa)
                targetDir = true,
              },
              -- clippy on save (replaces the old checkOnSave.command setting)
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = { enable = true },
              imports = {
                granularity = { group = "module" },
                prefix = "self",
              },
              inlayHints = {
                bindingModeHints = { enable = false },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
                parameterHints = { enable = true },
              },
              lens = {
                enable = true,
                run = { enable = true },
                debug = { enable = true },
                implementations = { enable = true },
                references = {
                  adt = { enable = false },
                  method = { enable = false },
                  trait = { enable = false },
                },
              },
              files = {
                exclude = { ".git", ".direnv", "node_modules", "target" },
              },
            },
          },
        },
      }
    end,
  },

  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = { enabled = true }, -- complete crate names, not just versions
      },
      -- In-process LSP: completion, hover and code actions flow through the
      -- normal LSP keymaps/nvim-cmp instead of a separate cmp source
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
      popup = { border = "rounded" },
    },
    keys = {
      { "<leader>Cu", function() require("crates").upgrade_crate() end, ft = "toml", desc = "Crates: upgrade crate" },
      { "<leader>CU", function() require("crates").upgrade_all_crates() end, ft = "toml", desc = "Crates: upgrade all" },
      { "<leader>Cf", function() require("crates").show_features_popup() end, ft = "toml", desc = "Crates: features" },
      { "<leader>Cv", function() require("crates").show_versions_popup() end, ft = "toml", desc = "Crates: versions" },
      { "<leader>Cd", function() require("crates").open_documentation() end, ft = "toml", desc = "Crates: docs.rs" },
    },
  },

  {
    "cordx56/rustowl",
    version = "*",
    lazy = false, -- already lazy (ftplugin)
    -- Only load once the `rustowl` binary is installed (see install.sh)
    cond = function() return vim.fn.executable("rustowl") == 1 end,
    opts = {
      auto_enable = false, -- toggle with <leader>Ro in Rust buffers
      idle_time = 500,
    },
  },
}
