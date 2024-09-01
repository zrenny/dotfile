local diagnostic = vim.diagnostic
local buf = vim.lsp.buf
local cmd = vim.cmd
local api = vim.api
local telescope_builtin = require("telescope.builtin")
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")
local dapui = require("dapui")
local dap = require("dap")
local dap_go = require("dap-go")
local ufo = require("ufo")

local function keymap(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local chad = api.nvim_create_augroup("Chad", {
  clear = false,
})
keymap("c", "<C-a>", "<Home>")
-- Nvimtree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>")
keymap("n", "<leader>nf", ":NvimTreeFocus<CR>")

-- Telescope
keymap("n", "<leader>lg", telescope_builtin.live_grep)
keymap("n", "<leader>ff", telescope_builtin.find_files)
keymap("n", "<leader>gf", telescope_builtin.git_files)
keymap("n", "<leader>gs", telescope_builtin.grep_string)
keymap("n", "<leader>fb", telescope_builtin.buffers)

-- Harpoon
keymap("n", "<leader>a", harpoon_mark.add_file)
keymap("n", "<leader>e", harpoon_ui.toggle_quick_menu)
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
keymap("n", "<leader>u", cmd.UndotreeToggle)

-- Git fugitive
keymap("n", "<leader>git", cmd.Git)
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
keymap("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
keymap("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
keymap("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
keymap("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
keymap("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
keymap("n", "<leader>B", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Breakpoint" })
keymap("n", "<F6>", dapui.toggle, { desc = "Debug: See last session result" })
keymap("n", "<F7>", ":lua require('dapui').open({reset = true})<CR>", { desc = "Debug: Open dapui" })
keymap("n", "<F8>", dapui.float_element, { desc = "Debug: Open floating window" })
keymap("n", "<F9>", dapui.eval, { desc = "Debug: Evaluate" })
-- keymap("n", "<leader>dgt", dap_go.debug_test(), { desc = "Debug: Go test cases" })
-- keymap("n", "<leader>dgl", dap_go.debug_last(), { desc = "Debug: Go debug last run test cases" })

-- Ufo/fold
keymap("n", "zR", ufo.openAllFolds)
keymap("n", "zM", ufo.closeAllFolds)
keymap("n", "zK", function()
  local winid = ufo.peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end)

-- lsp
keymap("n", "<leader>of", diagnostic.open_float)
keymap("n", "[d", diagnostic.goto_prev)
keymap("n", "]d", diagnostic.goto_next)
keymap("n", "<leader>sl", diagnostic.setloclist)

api.nvim_create_autocmd("LspAttach", {
  group = chad,
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    --    local bufnr = api.nvim_get_current_buf()

    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local opts = { buffer = ev.buf }
    keymap("n", "gD", buf.declaration, opts)
    keymap("n", "gd", buf.definition, opts)
    keymap("n", "K", buf.hover, opts)
    keymap("n", "gi", buf.implementation, opts)
    keymap("n", "<A-k>", buf.signature_help, opts)
    -- keymap('n', '<leader>wa', buf.add_workleader_folder, opts)
    -- keymap('n', '<leader>wr', buf.remove_workleader_folder, opts)
    -- keymap('n', '<leader>wl', function()
    --   print(vim.inspect(buf.list_workleader_folders()))
    -- end, opts)
    keymap("n", "<leader>D", buf.type_definition, opts)
    keymap("n", "<leader>rn", buf.rename, opts)
    keymap({ "n", "v" }, "<leader>ca", buf.code_action, opts)
    keymap("n", "gr", buf.references, opts)
    keymap("n", "<leader>f", function()
      buf.format({ async = true })
    end, opts)
  end,
})
