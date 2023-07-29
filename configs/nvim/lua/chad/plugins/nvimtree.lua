local function on_attach(bufnr)
  local api = require("nvim-tree.api")

  local keymap = vim.keymap.set

  local opts = {
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true,
  }

  api.config.mappings.default_on_attach(bufnr)

  keymap("n", "h", api.node.open.horizontal, opts)
  keymap("n", "v", api.node.open.vertical, opts)
end

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  cmd = "NvimTreeToggle",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      on_attach = on_attach,
      disable_netrw = true,
      hijack_netrw = true,
      open_on_tab = false,
      hijack_cursor = false,
      update_cwd = true,
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      diagnostics = {
        enable = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      git = {
        enable = true,
        ignore = true,
        timeout = 500,
      },
      view = {
        width = 30,
        hide_root_folder = false,
        side = "left",
        number = false,
        relativenumber = false,
      },
      renderer = {
        highlight_git = true,
        root_folder_modifier = ":t",
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            git = {
              unstaged = "",
              staged = "S",
              unmerged = "",
              renamed = "➜",
              deleted = "",
              untracked = "U",
              ignored = "◌",
            },
            folder = {
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
            },
          },
        },
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
        update_cwd = true,
      },
    })
  end,
}
