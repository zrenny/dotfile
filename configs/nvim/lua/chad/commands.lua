-- Function to reverse comma-separated values, supporting visual selection
function Reverse(opts)
  -- Get the start and end positions of the visual selection
  local start_pos = vim.fn.getpos("'<") -- Start of the visual selection
  local end_pos = vim.fn.getpos("'>")  -- End of the visual selection

  -- Ensure the visual selection is within a single line
  if start_pos[2] ~= end_pos[2] then
    print("This function only supports reversing within a single line.")
    return
  end

  -- Get the current line content
  local line = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, start_pos[2], false)[1]

  -- Preserve the existing indentation (whitespace at the beginning)
  local indentation = line:match("^%s*")

  -- Get the correct columns for the selected text (adjusted for Lua 1-based indexing)
  local start_col = math.min(start_pos[3], end_pos[3])
  local end_col = math.max(start_pos[3], end_pos[3])

  -- Extract the selected portion within the line
  local selected_text = string.sub(line, start_col, end_col)

  -- Split the selected portion by commas and trim spaces
  local values = {}
  for value in string.gmatch(selected_text, "([^,]+)") do
    table.insert(values, vim.trim(value)) -- Trim spaces
  end

  -- Reverse the values
  local reversed_values = {}
  for i = #values, 1, -1 do
    table.insert(reversed_values, values[i])
  end

  -- Join reversed values back into a string with comma and space, except the last value
  local reversed_text = table.concat(reversed_values, ", ")

  -- Rebuild the line by replacing only the selected portion
  local new_line = line:sub(1, start_col - 1) .. reversed_text .. line:sub(end_col + 1)

  -- Add back the preserved indentation
  new_line = indentation .. new_line:sub(#indentation + 1)

  -- Update the buffer with the modified line
  vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, start_pos[2], false, { new_line })

  -- Manually move the cursor to where it was before
  vim.api.nvim_win_set_cursor(0, { start_pos[2], start_col - 1 })
end

-- Create a command for reversing values
vim.api.nvim_create_user_command("Reverse", function(opts)
  Reverse(opts)
end, { range = true })

-- Function to sort comma-separated values, supporting visual selection
function SortInline(opts)
  -- Get the start and end positions of the visual selection
  local start_pos = vim.fn.getpos("'<") -- Start of the visual selection
  local end_pos = vim.fn.getpos("'>")  -- End of the visual selection

  -- Ensure that the visual selection is within a single line
  if start_pos[2] ~= end_pos[2] then
    print("This function only supports sorting within a single line.")
    return
  end

  -- Get the current line content
  local line = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, start_pos[2], false)[1]

  -- Preserve the existing indentation (whitespace at the beginning)
  local indentation = line:match("^%s*")

  -- Calculate the correct column positions for the selected text
  local start_col = math.min(start_pos[3], end_pos[3])
  local end_col = math.max(start_pos[3], end_pos[3])

  -- Extract the selected portion within the line
  local selected_text = string.sub(line, start_col, end_col)

  -- Split the selected portion by commas and trim spaces
  local values = {}
  for value in string.gmatch(selected_text, "([^,]+)") do
    table.insert(values, vim.trim(value)) -- Trim spaces
  end

  -- Sort the values based on the flag
  if opts.args == "-d" then
    table.sort(values, function(a, b)
      return a > b
    end)             -- Descending
  else
    table.sort(values) -- Ascending
  end

  -- Join sorted values back into a string separated by commas (no extra spaces)
  local sorted_text = table.concat(values, ", ")

  -- Rebuild the line by replacing only the selected portion
  local new_line = line:sub(1, start_col - 1) .. sorted_text .. line:sub(end_col + 1)

  -- Add back the preserved indentation
  new_line = indentation .. new_line:sub(#indentation + 1)

  -- Update the buffer with the modified line
  vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, start_pos[2], false, { new_line })
end

-- Function to change working directory based on the current nvim-tree node
function ChangeNvimTreeCwd()
  local lib = require("nvim-tree.api")
  local node = lib.tree.get_node_under_cursor()
  if not node or not node.absolute_path then
    print("No valid node found")
    return
  end

  local new_cwd
  if node.type == "directory" then
    new_cwd = node.absolute_path
  else
    -- For a file, use its parent directory
    new_cwd = vim.fn.fnamemodify(node.absolute_path, ":h")
  end

  if new_cwd and #new_cwd > 0 then
    vim.cmd("cd " .. new_cwd)
    print("Working directory changed to " .. new_cwd)
  end
end

-- Create a command that accepts the "-d" flag for descending order
vim.api.nvim_create_user_command("SortInline", SortInline, {
  nargs = "?",
  range = true,
  complete = function(_, _, _)
    return { "-d" }
  end,
})

-- Create an autocommand to map the key only in nvim-tree buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>cd",
      ":lua ChangeNvimTreeCwd()<CR>",
      { noremap = true, silent = true }
    )
  end,
})

vim.api.nvim_create_autocmd("CursorMovedI", {
  callback = function()
    require("luasnip").unlink_current()
  end,
})
