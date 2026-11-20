-- Replaces registers.nvim (its GitHub repo was deleted upstream). which-key
-- previews registers on `"` (normal) and <C-r> (insert), and shows the
-- keymap descriptions, e.g. everything under <leader>R in Rust buffers.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "classic",
    plugins = { registers = true },
    spec = {
      { "<leader>R", group = "rust" },
      { "<leader>Ri", group = "miri (UB checker)" },
      { "<leader>Rv", group = "tests with output (--nocapture)" },
      { "<leader>C", group = "crates (Cargo.toml)" },
      { "<leader>b", group = "buffer / breakpoint" },
      { "<leader>f", group = "find / format" },
      { "<leader>g", group = "git / grep" },
      { "<leader>h", group = "harpoon" },
      { "<leader>l", group = "loclist / live grep" },
      { "gr", group = "LSP (Neovim defaults)" },
      { "<leader>q", group = "quickfix" },
      { "<leader>s", group = "diagnostics → list" },
      -- nvim-cmp hard-codes a generic description on its keys; label them here
      {
        mode = "i",
        { "<C-Space>", desc = "Completion: open menu" },
        { "<C-e>", desc = "Completion: close menu" },
        { "<C-j>", desc = "Completion: next item" },
        { "<C-k>", desc = "Completion: previous item" },
        { "<CR>", desc = "Completion: confirm" },
        { "<Tab>", desc = "Completion: next item / snippet jump" },
        { "<S-Tab>", desc = "Completion: previous item / snippet jump back" },
        { "<M-d>", desc = "Completion: scroll docs down" },
        { "<M-u>", desc = "Completion: scroll docs up" },
      },
    },
  },
}
