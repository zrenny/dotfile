local function setup_go_autocommand()
  -- Create the autocommand group
  local abbrev = vim.api.nvim_create_augroup("abbrev", { clear = true })

  -- Create an autocommand for Go files only
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go", -- Use 'go' as the filetype, not '*.go'
    group = abbrev,
    callback = function()
      -- Use iabbrev for Go files, with proper escaping
      vim.cmd([[iabbrev <buffer> grt@ go func() {}()<C-o>2h<CR>]])
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = abbrev,
    callback = function()
      vim.cmd([[iabbrev <buffer> fori@ for i := 0; i <z; i++ {}<Left><CR><Esc>?z<CR>xi]])
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = abbrev,
    callback = function()
      vim.cmd([[iabbrev <buffer> forj@ for j := 0; j <z; j++ {}<Left><CR><Esc>?z<CR>xi]])
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = abbrev,
    callback = function()
      vim.cmd([[iabbrev <buffer> fork@ for k := 0; k <z; k++ {}<Left><CR><Esc>?z<CR>xi]])
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = abbrev,
    callback = function()
      vim.cmd([[iabbrev <buffer> ienn@ if err != nil {}<left><CR>]])
    end,
  })
end

-- Export the setup function
return {
  setup_go_autocommand = setup_go_autocommand,
}
