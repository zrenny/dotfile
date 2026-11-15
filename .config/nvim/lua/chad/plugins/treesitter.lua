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
      require("nvim-treesitter").install(parsers) -- async; no-op when installed

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("chad_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not vim.treesitter.language.add(lang) then
            return -- no parser installed for this filetype
          end
          vim.treesitter.start(ev.buf, lang)
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
