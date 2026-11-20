-- Rust: rustaceanvim (rust-analyzer + cargo integration + debugging),
-- crates.nvim (Cargo.toml), RustOwl (ownership/lifetime visualisation).
-- Buffer keymaps for Rust live in after/ftplugin/rust.lua.

-- Prefer the rustup-managed rust-analyzer so it always matches the project's
-- toolchain (the rustup proxy also honours rust-toolchain.toml). Mason
-- prepends its bin dir to $PATH, so a leftover mason rust-analyzer would
-- otherwise shadow it.
local ra_logfile = vim.fn.tempname() .. "-rust-analyzer.log" -- :RustLsp logFile
local ra_bin -- resolved once per session

-- First rust-analyzer on $PATH that isn't in `skip_dir` (brew, mason, ...)
local function other_rust_analyzer(skip_dir)
  for _, dir in ipairs(vim.split(vim.env.PATH or "", ":", { trimempty = true })) do
    local candidate = vim.fs.joinpath(dir, "rust-analyzer")
    if vim.fs.normalize(dir) ~= skip_dir and vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
end

local function rust_analyzer_cmd()
  if not ra_bin then
    local bin = vim.fs.normalize(vim.fs.joinpath(vim.env.CARGO_HOME or vim.fs.joinpath(vim.env.HOME, ".cargo"), "bin"))
    local proxy = vim.fs.joinpath(bin, "rust-analyzer")
    if vim.fn.executable(proxy) == 1 then
      -- The rustup proxy exists even when the component isn't installed
      local ok, res = pcall(function()
        return vim.system({ vim.fs.joinpath(bin, "rustup"), "which", "rust-analyzer" }):wait()
      end)
      if ok and res.code == 0 then
        ra_bin = proxy
      else
        ra_bin = other_rust_analyzer(bin)
        vim.notify(
          "rust-analyzer isn't installed for your rustup toolchain: run `rustup component add rust-analyzer`"
            .. (ra_bin and ("\nUsing " .. ra_bin .. " for now.") or ""),
          vim.log.levels.WARN
        )
      end
    else
      ra_bin = other_rust_analyzer(nil)
    end
    -- Nothing usable: a non-executable name makes rustaceanvim skip attaching
    -- instead of launching a server that immediately crashes.
    ra_bin = ra_bin or "rust-analyzer (not installed)"
  end
  return { ra_bin, "--log-file", ra_logfile }
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
          -- Single tests run in the background; failures show as diagnostics
          test_executor = "background",
          -- Everything else (runnables, whole-crate tests, ▶ Run lenses) uses
          -- one shared bottom split that the next run replaces (chad/runner.lua)
          executor = require("chad.runner").executor,
          crate_test_executor = require("chad.runner").executor,
          code_actions = { ui_select_fallback = true },
        },
        server = {
          cmd = rust_analyzer_cmd,
          logfile = ra_logfile,
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
      auto_enable = false, -- toggle with <leader>Rb in Rust buffers
      idle_time = 500,
    },
  },
}
