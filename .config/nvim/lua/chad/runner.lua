-- One shared output area at the bottom for cargo commands: tests and runs
-- (rustaceanvim), Miri and `cargo doc` (after/ftplugin/rust.lua).
-- A new run replaces the previous one in the same place, so splits never
-- pile up; runs that are still going are stopped. Your cursor stays where it
-- was. Close it with `q` inside it, or <leader>Rq from a Rust buffer.
-- Usually one pane; run_panes() shows several runs side by side (e.g. Miri
-- under both aliasing models).
local M = {}

local HEIGHT = 12
-- the panes currently shown: their windows and (terminal) buffers
local state = { wins = {}, bufs = {} }

local function valid(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

function M.close()
  -- forget the buffers first: closing wipes them and stops their jobs, and
  -- those jobs' on_exit mustn't be reported (e.g. as "cargo doc failed")
  local wins = state.wins
  state.wins, state.bufs = {}, {}
  for _, w in ipairs(wins) do
    -- if it's the last window, closing would fail; leave it then
    if valid(w) then pcall(vim.api.nvim_win_close, w, true) end
  end
end

---@class chad.Pane
---@field cmd string[]
---@field cwd? string
---@field env? table<string, string>
---@field title? string shown at the top of the pane
---@field on_exit? fun(code: integer) only called if this run wasn't replaced or closed

---@param panes chad.Pane[] shown side by side, left to right
function M.run_panes(panes)
  local old_wins, old_bufs = state.wins, state.bufs
  local bufs = {}
  for i = 1, #panes do bufs[i] = vim.api.nvim_create_buf(false, true) end
  -- from here on, on_exit of the previous runs is ignored
  state.bufs = bufs

  -- reuse the first window if it's in this tab (started from another tab,
  -- the output moves here); close the rest. Closing/replacing wipes the old
  -- buffers, which stops their jobs.
  local first = old_wins[1]
  if valid(first) and vim.api.nvim_win_get_tabpage(first) ~= vim.api.nvim_get_current_tabpage() then
    pcall(vim.api.nvim_win_close, first, true)
  end
  for i = 2, #old_wins do
    if valid(old_wins[i]) then pcall(vim.api.nvim_win_close, old_wins[i], true) end
  end
  if valid(first) then
    vim.api.nvim_win_set_buf(first, bufs[1])
  else
    first = vim.api.nvim_open_win(bufs[1], false, { split = "below", win = -1, height = HEIGHT })
    vim.wo[first].winfixheight = true
  end
  local wins = { first }
  for i = 2, #panes do
    wins[i] = vim.api.nvim_open_win(bufs[i], false, { split = "right", win = wins[i - 1] })
  end
  state.wins = wins
  if #wins > 1 then -- equal widths
    local total = 0
    for _, w in ipairs(wins) do total = total + vim.api.nvim_win_get_width(w) end
    for i = 1, #wins - 1 do vim.api.nvim_win_set_width(wins[i], math.floor(total / #wins)) end
  end
  for _, b in ipairs(old_bufs) do
    if vim.api.nvim_buf_is_valid(b) then pcall(vim.api.nvim_buf_delete, b, { force = true }) end
  end

  for i, pane in ipairs(panes) do
    local buf, win = bufs[i], wins[i]
    vim.bo[buf].bufhidden = "wipe"
    vim.keymap.set("n", "q", M.close, { buffer = buf, desc = "Close runner" })
    vim.wo[win].winbar = pane.title and (" " .. pane.title:gsub("%%", "%%%%")) or ""
    vim.api.nvim_win_call(win, function()
      vim.fn.jobstart(pane.cmd, {
        term = true,
        cwd = pane.cwd,
        env = pane.env,
        on_exit = function(_, code)
          vim.schedule(function()
            -- ignore runs that were replaced by a newer one or closed (q, :q):
            -- their job was stopped, it didn't fail
            if vim.tbl_contains(state.bufs, buf) and vim.api.nvim_buf_is_valid(buf) and pane.on_exit then
              pane.on_exit(code)
            end
          end)
        end,
      })
      vim.cmd("normal! G") -- follow the output
    end)
  end
end

---@class chad.RunOpts
---@field cwd? string
---@field env? table<string, string>
---@field on_exit? fun(code: integer) only called if this run wasn't replaced or closed

---@param cmd string[]
---@param opts? chad.RunOpts
function M.run(cmd, opts)
  opts = opts or {}
  M.run_panes({ { cmd = cmd, cwd = opts.cwd, env = opts.env, on_exit = opts.on_exit } })
end

-- rustaceanvim executor (tools.executor / crate_test_executor)
---@type rustaceanvim.Executor
M.executor = {
  execute_command = function(command, args, cwd, opts)
    M.run(vim.list_extend({ command }, args or {}), { cwd = cwd, env = opts and opts.env })
  end,
}

return M
