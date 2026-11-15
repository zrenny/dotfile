local M = {}

local go_abbrevs = {
  [[grt@ go func() {}()<C-o>2h<CR>]],
  [[fori@ for i := 0; i <z; i++ {}<Left><CR><Esc>?z<CR>xi]],
  [[forj@ for j := 0; j <z; j++ {}<Left><CR><Esc>?z<CR>xi]],
  [[fork@ for k := 0; k <z; k++ {}<Left><CR><Esc>?z<CR>xi]],
  [[ienn@ if err != nil {}<left><CR>]],
}

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("abbrev", { clear = true }),
    pattern = "go",
    callback = function()
      for _, abbrev in ipairs(go_abbrevs) do
        vim.cmd("iabbrev <buffer> " .. abbrev)
      end
    end,
  })
end

return M
