-- Core (plugin-free) keymaps. Plugin keymaps live in each plugin spec's `keys`,
-- LSP keymaps in lua/chad/lsp.lua, Rust keymaps in after/ftplugin/rust.lua.
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
end

local function close_floating()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false) -- some floats refuse to close
    end
  end
end

map("", "<Space>", "<Nop>")
map("c", "<C-a>", "<Home>", { silent = false })

-- Normal --
map("n", "L", "$")
map("n", "H", "^")
map("n", "<ESC>", close_floating)

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Quickfix
map("n", "co", "<cmd>copen<CR>")
map("n", "cc", "<cmd>cclose<CR>")
map("n", "cj", "<cmd>cnext<CR>zz")
map("n", "ck", "<cmd>cprev<CR>zz")

-- Location list
map("n", "lo", "<cmd>lopen<CR>")
map("n", "lc", "<cmd>lclose<CR>")
map("n", "lj", "<cmd>lnext<CR>zz")
map("n", "lk", "<cmd>lprev<CR>zz")

-- Resize
map("n", "<A-Up>", "<cmd>resize +2<CR>")
map("n", "<A-Down>", "<cmd>resize -2<CR>")
map("n", "<A-Left>", "<cmd>vertical resize +2<CR>")
map("n", "<A-Right>", "<cmd>vertical resize -2<CR>")

-- Buffers
map("n", "<TAB>", "<cmd>bn<CR>")
map("n", "<S-TAB>", "<cmd>bp<CR>")
map("n", "<leader>bd", "<cmd>bd<CR>")
map("n", "<leader>bda", "<cmd>bd | bd<CR>")

-- System clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- Insert --
map("i", "<C-b>", "<C-o>db")
map("i", "<C-w>", "<C-o>dw")
map("i", "<C-u>", "<C-o>d^")
map("i", "<C-d>", "<C-o>D")
map("i", "<C-h>", "<C-o><<")
map("i", "<C-l>", "<C-o>>>")
map("i", "jk", "<ESC>")

-- Visual --
map("v", "<", "<gv")
map("v", ">", ">gv")
map({ "v", "x" }, "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>d", [["_d]])
map({ "n", "v" }, "<leader>c", [["_c]])
map("n", "<leader>x", [["_x]])
map("x", "J", ":move '>+1<CR>gv-gv")
map("x", "K", ":move '<-2<CR>gv-gv")
map({ "v", "x" }, "H", "^")
map({ "v", "x" }, "L", "$")

-- Terminal --
map("t", "<A-Up>", "<cmd>resize +2<CR>")
map("t", "<A-Down>", "<cmd>resize -2<CR>")
map("t", "<A-Left>", "<cmd>vertical resize -2<CR>")
map("t", "<A-Right>", "<cmd>vertical resize +2<CR>")
