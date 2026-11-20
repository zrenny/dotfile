-- One shared output split at the bottom for cargo commands: tests and runs
-- (rustaceanvim), Miri and `cargo doc` (after/ftplugin/rust.lua).
-- A new run replaces the previous one in the same window, so splits never
-- pile up; a run that's still going is stopped. Your cursor stays where it
-- was. Close it with `q` inside it, or <leader>Rq from a Rust buffer.
local M = {}

local HEIGHT = 12
local state = { win = nil, buf = nil }

local function win_ok()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.close()
  if win_ok() then
    -- if it's the last window, closing would fail; leave it then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
  -- closing wipes the buffer and stops its job; forget it so that job's
  -- on_exit isn't reported (e.g. as "cargo doc failed")
  state.buf = nil
end

---@class chad.RunOpts
---@field cwd? string
---@field env? table<string, string>
---@field on_exit? fun(code: integer) only called if this run wasn't replaced

---@param cmd string[]
---@param opts? chad.RunOpts
function M.run(cmd, opts)
  opts = opts or {}
  -- the split lives in one tab; started from another tab, move it here
  if win_ok() and vim.api.nvim_win_get_tabpage(state.win) ~= vim.api.nvim_get_current_tabpage() then
    pcall(vim.api.nvim_win_close, state.win, true)
    state.win = nil
  end
  local old = state.buf
  local buf = vim.api.nvim_create_buf(false, true)
  state.buf = buf
  if win_ok() then
    vim.api.nvim_win_set_buf(state.win, buf)
  else
    state.win = vim.api.nvim_open_win(buf, false, { split = "below", win = -1, height = HEIGHT })
    vim.wo[state.win].winfixheight = true
  end
  -- the previous run: stop its job (if still going) and drop its buffer
  if old and vim.api.nvim_buf_is_valid(old) then
    pcall(vim.api.nvim_buf_delete, old, { force = true })
  end
  vim.bo[buf].bufhidden = "wipe"
  vim.keymap.set("n", "q", M.close, { buffer = buf, desc = "Close runner" })

  vim.api.nvim_win_call(state.win, function()
    vim.fn.jobstart(cmd, {
      term = true,
      cwd = opts.cwd,
      env = opts.env,
      on_exit = function(_, code)
        vim.schedule(function()
          -- ignore runs that were replaced by a newer one or closed (q, :q):
          -- their job was stopped, it didn't fail
          if state.buf == buf and vim.api.nvim_buf_is_valid(buf) and opts.on_exit then
            opts.on_exit(code)
          end
        end)
      end,
    })
    vim.cmd("normal! G") -- follow the output
  end)
end

-- rustaceanvim executor (tools.executor / crate_test_executor)
---@type rustaceanvim.Executor
M.executor = {
  execute_command = function(command, args, cwd, opts)
    M.run(vim.list_extend({ command }, args or {}), { cwd = cwd, env = opts and opts.env })
  end,
}

return M
