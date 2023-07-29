return {
  "anuvyklack/pretty-fold.nvim",
  event = "BufEnter",
  config = function()
    local fold = require("pretty-fold")
    local base_matchup_patterns = {
      { "{",  "}" },
      { "%(", ")" }, -- % to escape lua pattern char
      { "%[", "]" }, -- % to escape lua pattern char
    }
    local lua_matchup_patterns = {
      -- ╟─ Start of line ──╭───────╮── "do" ── End of line ─╢
      --                    ╰─ WSP ─╯
      { "^%s*do$",       "end" }, -- `do ... end` blocks

      -- ╟─ Start of line ──╭───────╮── "if" ─╢
      --                    ╰─ WSP ─╯
      { "^%s*if",        "end" },

      -- ╟─ Start of line ──╭───────╮── "for" ─╢
      --                    ╰─ WSP ─╯
      { "^%s*for",       "end" },

      -- ╟─ "function" ──╭───────╮── "(" ─╢
      --                 ╰─ WSP ─╯
      { "function%s*%(", "end" }, -- 'function(' or 'function ('
    }

    fold.setup({
      sections = {
        left = {
          "content",
        },
        right = {
          " ",
          "number_of_folded_lines",
          ": ",
          "percentage",
          " ",
          function(config)
            return config.fill_char:rep(3)
          end,
        },
      },
      fill_char = "•",

      remove_fold_markers = true,

      -- Keep the indentation of the content of the fold string.
      keep_indentation = true,

      -- Possible values:
      -- "delete" : Delete all comment signs from the fold string.
      -- "spaces" : Replace all comment signs with equal number of spaces.
      -- false    : Do nothing with comment signs.
      process_comment_signs = "spaces",

      -- Comment signs additional to the value of `&commentstring` option.
      comment_signs = {},

      -- List of patterns that will be removed from content foldtext section.
      stop_words = {
        "@brief%s*", -- (for C++) Remove '@brief' and all spaces after.
      },

      add_close_pattern = true, -- true, 'last_line' or false

      matchup_patterns = base_matchup_patterns,

      ft_ignore = { "neorg" },
    })

    fold.ft_setup("lua", {
      matchup_patterns = vim.tbl_deep_extend("force", base_matchup_patterns, lua_matchup_patterns),
    })
  end,
}
