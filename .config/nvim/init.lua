-- rustaceanvim (^9) and the nvim-treesitter `main` branch both require 0.12.
if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "This config needs Neovim >= 0.12 (brew upgrade neovim)", "ErrorMsg" } }, true, {})
end

-- Leader must be set before lazy.nvim loads any plugin `keys`.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("chad.options")
require("chad.keymaps")
require("chad.autocmds")
require("chad.commands")
require("chad.abbrev").setup()
require("chad.lsp").setup()
require("chad.lazy")
