local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set
local function close_floating()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end
end
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

keymap("c", "<C-a>", "<Home>")

function RemoveCurrentQuickfixEntry()
  local qflist = vim.fn.getqflist()
  local lnum = vim.fn.line(".") - 1
  table.remove(qflist, lnum + 1)
  vim.fn.setqflist(qflist)
  vim.cmd("copen")
end

-- Set keymap only inside the Quickfix window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>dc",
      ":lua RemoveCurrentQuickfixEntry()<CR>",
      { noremap = true, silent = true }
    )
  end,
})

function RemoveCurrentLocListEntry()
  local loclist = vim.fn.getloclist(0)
  local lnum = vim.fn.line(".") - 1
  table.remove(loclist, lnum + 1)
  vim.fn.setloclist(0, loclist)
  vim.cmd("lopen")
end

-- Set keymap only inside the Location list window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>dl",
      ":lua RemoveCurrentLocListEntry()<CR>",
      { noremap = true, silent = true }
    )
  end,
})

-- Normal --
keymap("n", "L", "$", opts)
keymap("n", "H", "^", opts)
keymap("n", "<ESC>", close_floating, opts)
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "J", "mzJ`z", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Quick fix
keymap("n", "co", "<cmd>copen<CR>", opts)
keymap("n", "cc", "<cmd>cclose<CR>", opts)
keymap("n", "cj", "<cmd>cnext<CR>zz", opts)
keymap("n", "ck", "<cmd>cprev<CR>zz", opts)

-- Local list
keymap("n", "lo", "<cmd>lopen<CR>", opts)
keymap("n", "lc", "<cmd>lclose<CR>", opts)
keymap("n", "lj", "<cmd>lnext<CR>zz", opts)
keymap("n", "lk", "<cmd>lprev<CR>zz", opts)

-- Resize with arrows
keymap("n", "<A-Up>", ":resize +2<CR>", opts)
keymap("n", "<A-Down>", ":resize -2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize +2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize -2<CR>", opts)

keymap("n", "<TAB>", ":bn<CR>", opts)
keymap("n", "<S-TAB>", ":bp<CR>", opts)
keymap("n", "<leader>bd", ":bd<CR>", opts)
keymap("n", "<leader>bda", ":bd | :bd<CR>", opts)

-- Pasting to system clipboard
keymap({ "n", "v" }, "<leader>y", [["+y]], opts)
keymap("n", "<leader>Y", [["+Y]], opts)

-- Navigate buffers
-- keymap("n", "<S-l>", ":bnext<CR>", opts)
-- keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
-- keymap("n", "<A-j>", ":m .+1<CR>==", opts)
-- keymap("n", "<A-k>", ":m .-2<CR>==", opts)

-- Insert -- Press jk fast
keymap("i", "<C-b>", "<C-o>db", opts)
keymap("i", "<C-w>", "<C-o>dw", opts)
keymap("i", "<C-u>", "<C-o>d^", opts)
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
keymap({ "v", "x" }, "<Leader>p", [["_dP]], opts)
-- Delete and change without affecting registers
keymap({ "n", "v" }, "<Leader>d", [["_d]], opts)
keymap({ "n", "v" }, "<Leader>c", [["_c]], opts)
keymap("n", "<Leader>x", [["_x]], opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
-- keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

keymap({ "v", "x" }, "H", "^", opts)
keymap({ "v", "x" }, "L", "$", opts)

-- Terminal --
keymap("t", "<A-Up>", "<cmd>resize +2<CR>", opts)
keymap("t", "<A-Down>", "<cmd>resize -2<CR>", opts)
keymap("t", "<A-Left>", "<cmd>vertical resize -2<CR>", opts)
keymap("t", "<A-Right>", "<cmd>vertical resize +2<CR>", opts)
