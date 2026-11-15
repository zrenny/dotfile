-- Maintained fork of norcalli/nvim-colorizer.lua (the original is unmaintained
-- and calls vim.tbl_flatten, which is removed in Neovim 0.13).
return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {},
}
