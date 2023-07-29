local hl = vim.api.nvim_set_hl
local cmd = vim.cmd


return {
  "edeneast/nightfox.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    cmd([[colorscheme carbonfox]])
    hl(0, "Normal", { bg = "none" })
    hl(0, "NormalNC", { bg = "none" })
    hl(0, "Normalfloat", { bg = "none" })
    hl(0, "Visual", { bg = "#757575" })
    hl(0, "NvimTreeNormal", { bg = "none", ctermbg = "none"})
  end,
}
