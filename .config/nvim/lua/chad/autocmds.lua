local group = vim.api.nvim_create_augroup("chad", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

-- Drop the entry under the cursor from the quickfix / location list.
local function remove_list_entry(loclist)
  local list = loclist and vim.fn.getloclist(0) or vim.fn.getqflist()
  table.remove(list, vim.fn.line("."))
  if loclist then
    vim.fn.setloclist(0, list)
    vim.cmd("lopen")
  else
    vim.fn.setqflist(list)
    vim.cmd("copen")
  end
end

autocmd("FileType", {
  pattern = "qf",
  callback = function(ev)
    vim.keymap.set("n", "<leader>dc", function() remove_list_entry(false) end, { buffer = ev.buf, desc = "Remove quickfix entry" })
    vim.keymap.set("n", "<leader>dl", function() remove_list_entry(true) end, { buffer = ev.buf, desc = "Remove loclist entry" })
  end,
})

autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

autocmd("TermOpen", {
  desc = "Terminal-mode navigation (toggleterm, :RustLsp runnables, etc.)",
  callback = function(ev)
    local o = { buffer = ev.buf }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], o)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
  end,
})
