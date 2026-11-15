-- nvim-treesitter `main` branch (the old `master` branch is frozen and doesn't
-- support Neovim 0.12). It only installs parsers/queries now; highlighting,
-- indent and folds are switched on per buffer below.
-- Requires the tree-sitter CLI (`brew install tree-sitter-cli`) and a C compiler.
local parsers = {
  -- Rust
  "rust", "toml", "ron",
  -- Go
  "go", "gomod", "gosum", "gowork", "gotmpl",
  -- Systems / build
  "c", "cpp", "cmake", "make", "dockerfile",
  -- Web
  "html", "css", "scss", "javascript", "typescript", "tsx", "graphql", "prisma", "php",
  -- Data / config
  "json", "yaml", "xml", "sql", "hcl", "terraform", "helm", "kdl",
  -- Scripting
  "bash", "lua", "luadoc", "python", "kotlin", "typst",
  -- Neovim / docs / git
  "vim", "vimdoc", "query", "regex", "markdown", "markdown_inline", "comment",
  "diff", "gitcommit", "git_rebase", "git_config", "gitignore",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      if type(ts.install) ~= "function" then
        -- One-time migration: this install is still on the old `master`
        -- branch (no install()). lazy.nvim only switches branches on update,
        -- and if lazy-lock.json recorded the old master commit, reinstalling
        -- or :Lazy restore puts it right back. :Lazy update ignores the
        -- lockfile, moves to `main` and re-pins it, so do that automatically.
        vim.notify("nvim-treesitter: moving from the old `master` branch to `main`...", vim.log.levels.WARN)
        vim.schedule(function()
          require("lazy").update({ plugins = { "nvim-treesitter" }, show = false }):wait(function()
            vim.notify("nvim-treesitter is now on `main`. Restart Neovim to finish.", vim.log.levels.WARN)
          end)
        end)
        return
      end
      ts.install(parsers) -- async; no-op when installed

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("chad_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not vim.treesitter.language.add(lang) then
            return -- no parser installed for this filetype
          end
          -- pcall: a parser installed by something else may lack highlight queries
          if not pcall(vim.treesitter.start, ev.buf, lang) then
            return
          end
          if vim.treesitter.query.get(lang, "indents") then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 0,
      multiline_threshold = 1,
      trim_scope = "outer",
      mode = "cursor",
    },
  },
}
