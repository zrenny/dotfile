local opt = vim.opt

-- Files
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.fileencoding = "utf-8"

-- UI
opt.termguicolors = true
opt.cmdheight = 2
opt.showtabline = 2
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.guifont = "monospace:h17"
opt.guicursor = ""
opt.list = true
opt.listchars:append("space:⋅")
opt.fillchars:append("fold:•")
opt.winborder = "rounded" -- borders for LSP hover/signature/diagnostic floats (0.11+)
opt.conceallevel = 0

-- Editing
opt.clipboard = "unnamedplus"
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.iskeyword:append("-")
opt.whichwrap:append("<>[]hl")
opt.shortmess:append("c")

-- Search
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Windows / timing
opt.splitbelow = true
opt.splitright = true
opt.timeoutlen = 1000
opt.updatetime = 300

-- Folding (nvim-ufo)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
