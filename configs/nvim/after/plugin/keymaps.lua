local opts = { silent = true, noremap = true }
local keymap = vim.keymap.set
local cmd = vim.cmd
local api = vim.api
local telescope_builtin = require("telescope.builtin")
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")
local dapui = require("dapui")
local ufo = require("ufo")

local chad = api.nvim_create_augroup("Chad", {
  clear = false,
})

-- Nvimtree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>nf", ":NvimTreeFocus<CR>", opts)

-- Telescope
keymap("n", "<leader>lg", telescope_builtin.live_grep, opts)
keymap("n", "<leader>ff", telescope_builtin.find_files, opts)
keymap("n", "<leader>gf", telescope_builtin.git_files, opts)
keymap("n", "<leader>gs", telescope_builtin.grep_string, opts)

-- Harpoon
keymap("n", "<leader>a", harpoon_mark.add_file, opts)
keymap("n", "<leader>e", harpoon_ui.toggle_quick_menu, opts)
keymap("n", "<leader><F1>", function()
  harpoon_ui.nav_file(1)
end)
keymap("n", "<leader><F2>", function()
  harpoon_ui.nav_file(2)
end)
keymap("n", "<leader><F3>", function()
  harpoon_ui.nav_file(3)
end)
keymap("n", "<leader><F4>", function()
  harpoon_ui.nav_file(4)
end)

-- Undotree
keymap("n", "<leader>u", cmd.UndotreeToggle, opts)

-- Git fugitive
keymap("n", "<leader>gs", cmd.Git, opts)
api.nvim_create_autocmd("BufWinEnter", {
  group = chad,
  pattern = "*",
  callback = function()
    if vim.bo.ft ~= "fugitive" then
      return
    end

    local bufnr = api.nvim_get_current_buf()
    local opts = { buffer = bufnr, remap = false }
    keymap("n", "<leader>p", function()
      cmd.Git("push")
    end, opts)

    -- rebase always
    keymap("n", "<leader>P", function()
      cmd.Git({ "pull", "--rebase" })
    end, opts)

    -- NOTE: It allows me to easily set the branch i am pushing and any tracking
    -- needed if i did not set the branch up correctly
    keymap("n", "<leader>t", ":Git push -u origin<cr>", opts)
  end,
})

-- Dap
keymap("n", "<leader>dt", dapui.toggle, opts)
keymap("n", "<leader>db", cmd.DapToggleBreakpoint, opts)
keymap("n", "<leader>dc", cmd.DapContinue, opts)
keymap("n", "<leader>dr", ":lua require('dapui').open({reset = true})<CR>", opts)
keymap("n", "<leader>df", dapui.float_element, opts)
keymap("n", "<leader>de", dapui.eval, opts)

-- Ufo
keymap("n", "zR", ufo.openAllFolds, opts)
keymap("n", "zM", ufo.closeAllFolds, opts)
keymap("n", "zr", ufo.openFoldsExceptKinds, opts)
keymap("n", "zm", ufo.closeFoldsWith, opts)
keymap("n", "zK", function()
  local winid = ufo.peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, opts)
