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
      { "<leader>C", group = "crates (Cargo.toml)" },
      { "<leader>b", group = "buffer / breakpoint" },
      { "<leader>f", group = "find / format" },
      { "<leader>g", group = "git / grep" },
      { "<leader>h", group = "harpoon" },
      { "<leader>l", group = "loclist / live grep / lens" },
      { "<leader>q", group = "quickfix" },
      { "<leader>s", group = "diagnostics → list" },
    },
  },
}
