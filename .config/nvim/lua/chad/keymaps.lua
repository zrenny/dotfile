-- Core (plugin-free) keymaps. Plugin keymaps live in each plugin spec's `keys`,
-- LSP keymaps in lua/chad/lsp.lua, Rust keymaps in after/ftplugin/rust.lua.
--
-- Visual-mode maps use "x", not "v": "v" also covers *select* mode, which is
-- what snippet placeholders use, so e.g. a "v" map on H would turn typing
-- "Hello" over a placeholder into "^ello".
local function map(mode, lhs, rhs, desc, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true, desc = desc }, opts or {}))
end

local function close_floating()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false) -- some floats refuse to close
    end
  end
end

map({ "n", "x" }, "<Space>", "<Nop>", "Leader key")
map("c", "<C-a>", "<Home>", "Cmdline: go to start", { silent = false })

-- Normal --
map("n", "L", "$", "End of line")
map("n", "H", "^", "First non-blank of line")
map("n", "<ESC>", close_floating, "Close floating windows")

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")

map("n", "J", "mzJ`z", "Join lines (keep cursor)")
map("n", "<C-d>", "<C-d>zz", "Half page down (centred)")
map("n", "<C-u>", "<C-u>zz", "Half page up (centred)")
map("n", "n", "nzzzv", "Next match (centred)")
map("n", "N", "Nzzzv", "Previous match (centred)")

-- Quickfix / location list
-- (Previously co/cc/cj/ck and lo/lc/lj/lk: those hid Vim's `cc`/`c{motion}`
-- and made every lone `l` wait 'timeoutlen' before moving.)
-- ]q [q ]l [l are Neovim's defaults, redefined to keep the old re-centring;
-- they accept a count (3]q).
local function list_jump(cmd)
  return function()
    local ok, err = pcall(vim.cmd, vim.v.count1 .. cmd)
    if ok then
      vim.cmd("normal! zz")
    else
      vim.notify(err:match("E%d+:.*") or err, vim.log.levels.WARN) -- e.g. "E553: No more items"
    end
  end
end
map("n", "<leader>qo", "<cmd>copen<CR>", "Quickfix: open")
map("n", "<leader>qc", "<cmd>cclose<CR>", "Quickfix: close")
map("n", "]q", list_jump("cnext"), "Quickfix: next")
map("n", "[q", list_jump("cprev"), "Quickfix: previous")
map("n", "<leader>lo", "<cmd>lopen<CR>", "Loclist: open")
map("n", "<leader>lc", "<cmd>lclose<CR>", "Loclist: close")
map("n", "]l", list_jump("lnext"), "Loclist: next")
map("n", "[l", list_jump("lprev"), "Loclist: previous")

-- Resize
map("n", "<A-Up>", "<cmd>resize +2<CR>", "Taller window")
map("n", "<A-Down>", "<cmd>resize -2<CR>", "Shorter window")
map("n", "<A-Left>", "<cmd>vertical resize +2<CR>", "Wider window")
map("n", "<A-Right>", "<cmd>vertical resize -2<CR>", "Narrower window")

-- Buffers
map("n", "<TAB>", "<cmd>bn<CR>", "Next buffer")
map("n", "<S-TAB>", "<cmd>bp<CR>", "Previous buffer")
map("n", "<leader>bd", "<cmd>bd<CR>", "Delete buffer")
map("n", "<leader>bD", "<cmd>bd | bd<CR>", "Delete buffer twice") -- was <leader>bda (made <leader>bd pause)

-- System clipboard
map({ "n", "x" }, "<leader>y", [["+y]], "Yank to system clipboard")
map("n", "<leader>Y", [["+Y]], "Yank line to system clipboard")

-- Insert --
map("i", "<C-b>", "<C-o>db", "Delete word before cursor")
map("i", "<C-w>", "<C-o>dw", "Delete word after cursor")
map("i", "<C-u>", "<C-o>d^", "Delete to start of line")
map("i", "<C-d>", "<C-o>D", "Delete to end of line")
map("i", "<C-h>", "<C-o><<", "Dedent line")
map("i", "<C-l>", "<C-o>>>", "Indent line")
map("i", "jk", "<ESC>", "Exit insert mode")

-- Visual --
map("x", "<", "<gv", "Dedent (keep selection)")
map("x", ">", ">gv", "Indent (keep selection)")
map("x", "<leader>p", [["_dP]], "Paste without yanking selection")
map({ "n", "x" }, "<leader>d", [["_d]], "Delete without yanking")
map({ "n", "x" }, "<leader>c", [["_c]], "Change without yanking")
map("n", "<leader>x", [["_x]], "Delete char without yanking")
map("x", "J", ":move '>+1<CR>gv-gv", "Move selection down")
map("x", "K", ":move '<-2<CR>gv-gv", "Move selection up")
map("x", "H", "^", "First non-blank of line")
map("x", "L", "$", "End of line")

-- Terminal --
map("t", "<A-Up>", "<cmd>resize +2<CR>", "Taller window")
map("t", "<A-Down>", "<cmd>resize -2<CR>", "Shorter window")
map("t", "<A-Left>", "<cmd>vertical resize -2<CR>", "Narrower window")
map("t", "<A-Right>", "<cmd>vertical resize +2<CR>", "Wider window")
