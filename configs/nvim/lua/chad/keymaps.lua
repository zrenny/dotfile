local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
keymap("c", "<C-a>", "<Home>")
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Terminal navigation
-- keymap("t", "<esc>", [[<C-\><C-n>]], opts)
-- keymap("t", "jk", [[<C-\><C-n>]], opts)
-- keymap("t", "<C-h>", "<cmd>wincmd h<CR>", opts)
-- keymap("t", "<C-j>", "<cmd>wincmd j<CR>", opts)
-- keymap("t", "<C-k>", "<cmd>wincmd k<CR>", opts)
-- keymap("t", "<c-l>", "<cmd>wincmd l<cr>", opts)

keymap("n", "J", "mzJ`z", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Quick fix navigation
keymap("n", "fk", "<cmd>cnext<CR>zz", opts)
keymap("n", "fj", "<cmd>cprev<CR>zz", opts)
keymap("n", "<leader>k", "<cmd>lnext<CR>zz", opts)
keymap("n", "<leader>j", "<cmd>lprev<CR>zz", opts)

-- Resize with arrows
keymap("n", "<A-Up>", ":resize +2<CR>", opts)
keymap("n", "<A-Down>", ":resize -2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize +2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize -2<CR>", opts)

keymap("t", "<A-Up>", "<cmd>resize +2<CR>", opts)
keymap("t", "<A-Down>", "<cmd>resize -2<CR>", opts)
keymap("t", "<A-Left>", "<cmd>vertical resize -2<CR>", opts)
keymap("t", "<A-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
-- keymap("n", "<J>", "<Esc>:m .+1<CR>==gi", opts)
-- keymap("n", "<K>", "<Esc>:m .-2<CR>==gi", opts)

-- Insert -- Press jk fast
keymap("i", "<C-b>", "<C-o>db", opts)
keymap("i", "<C-w>", "<C-o>dw", opts)
keymap("i", "<C-d>", "<C-o>D", opts)
keymap("i", "<C-h>", "<C-o><<", opts)
keymap("i", "<C-l>", "<C-o>>>", opts)
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<J>", ":m .+1<CR>==", opts)
keymap("v", "<K>", ":m .-2<CR>==", opts)
-- Better pasting
keymap("v", "<Leader>p", [["_dP]], opts)
keymap("x", "<Leader>p", [["_dP]], opts)
-- Pasting to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]], opts)
keymap("n", "<leader>Y", [["+Y]], opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
-- keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

keymap("n", "<TAB>", ":bn<CR>", opts)
keymap("n", "<S-TAB>", ":bp<CR>", opts)
keymap("n", "<leader>bd", ":bd<CR>", opts)
keymap("n", "<leader>bda", ":bd | :bd<CR>", opts)
