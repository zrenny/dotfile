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

  -- cd into the node under the cursor (its parent dir for files)
  keymap("n", "<leader>cd", function()
    local node = api.tree.get_node_under_cursor()
    if not node or not node.absolute_path then
      return
    end
    local dir = node.type == "directory" and node.absolute_path or vim.fs.dirname(node.absolute_path)
    vim.cmd.cd(dir)
    vim.notify("cwd: " .. dir)
  end, opts)
end

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "File tree" },
    { "<leader>nf", "<cmd>NvimTreeFocus<CR>", desc = "Focus file tree" },
  },
  init = function()
    -- netrw is disabled, so `nvim .` / `nvim some/dir` needs nvim-tree loaded
    -- at startup to take over the directory buffer
    if vim.fn.argc(-1) == 1 then
      local stat = vim.uv.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("nvim-tree")
      end
    end
  end,
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
        },
    })
  end,
}
