-- :Reverse and :SortInline operate on a comma-separated, single-line visual selection.

---@param transform fun(values: string[]): string[]
local function edit_inline_list(transform)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  if start_pos[2] ~= end_pos[2] then
    vim.notify("Only works within a single line", vim.log.levels.WARN)
    return
  end

  local row = start_pos[2]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  local start_col = math.min(start_pos[3], end_pos[3])
  local end_col = math.max(start_pos[3], end_pos[3])

  local values = {}
  for value in line:sub(start_col, end_col):gmatch("([^,]+)") do
    table.insert(values, vim.trim(value))
  end

  local new_text = table.concat(transform(values), ", ")
  local new_line = line:sub(1, start_col - 1) .. new_text .. line:sub(end_col + 1)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { row, start_col - 1 })
end

vim.api.nvim_create_user_command("Reverse", function()
  edit_inline_list(function(values) return vim.fn.reverse(values) end)
end, { range = true, desc = "Reverse comma-separated values in selection" })

vim.api.nvim_create_user_command("SortInline", function(opts)
  edit_inline_list(function(values)
    table.sort(values, opts.args == "-d" and function(a, b) return a > b end or nil)
    return values
  end)
end, {
  nargs = "?",
  range = true,
  complete = function() return { "-d" } end,
  desc = "Sort comma-separated values in selection (-d for descending)",
})
