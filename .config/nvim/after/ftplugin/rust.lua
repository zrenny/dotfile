-- Rust buffer settings + keymaps (all under <leader>R).
-- K and <leader>ca are upgraded to rustaceanvim's versions in lua/chad/lsp.lua.
-- NOTE: don't set vim.g.rustaceanvim here; that's done in plugins/rust.lua.
local buf = vim.api.nvim_get_current_buf()

vim.opt_local.colorcolumn = "100" -- rustfmt's default max_width

local function map(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, silent = true, desc = "Rust: " .. desc })
end

local function rust(...)
  local args = { ... }
  return function()
    -- :RustLsp is only defined while rust-analyzer is running
    if vim.fn.exists(":RustLsp") ~= 2 then
      vim.notify("rust-analyzer isn't running (see :checkhealth rustaceanvim)", vim.log.levels.WARN)
      return
    end
    vim.cmd.RustLsp(args)
  end
end

local function rerun(subcmd)
  local f = rust(subcmd)
  return function()
    -- same guard, but with a bang to rerun the last target
    if vim.fn.exists(":RustLsp") == 2 then
      vim.cmd.RustLsp({ subcmd, bang = true })
    else
      f()
    end
  end
end

-- Run / test / debug (capital letter = rerun the last one)
map("<leader>Rr", rust("runnables"), "runnables")
map("<leader>RR", rerun("runnables"), "rerun last runnable")
map("<leader>Rt", rust("testables"), "testables")
map("<leader>RT", rerun("testables"), "rerun last test")
map("<leader>Rd", rust("debuggables"), "debuggables")
map("<leader>RD", rerun("debuggables"), "rerun last debuggable")

-- Diagnostics
map("<leader>Re", rust("explainError", "current"), "explain error")
map("<leader>Rx", rust("renderDiagnostic", "current"), "render diagnostic (cargo style)")
map("<leader>Rf", rust("relatedDiagnostics"), "related diagnostics")
map("<leader>Rk", rust("flyCheck", "run"), "run cargo check/clippy now")

-- Navigation
map("<leader>Rc", rust("openCargo"), "open Cargo.toml")
map("<leader>Rp", rust("parentModule"), "parent module")
map("<leader>Ro", rust("openDocs"), "open docs.rs for symbol")
map("<leader>Rs", rust("relatedTests"), "related tests")

-- Editing
map("<leader>Rm", rust("expandMacro"), "expand macro")
map("<leader>Rj", rust("joinLines"), "join lines")
map("<leader>Rj", ":RustLsp joinLines<CR>", "join selected lines", "v") -- needs the '<,'> range
map("<leader>Ru", rust("moveItem", "up"), "move item up")
map("<leader>Rn", rust("moveItem", "down"), "move item down")
map("<leader>Rh", rust("hover", "range"), "hover range (type of selection)", "v")
map("<leader>Rw", rust("reloadWorkspace"), "reload workspace")

-- RustOwl ownership/lifetime highlighting (only if the plugin is loaded)
if package.loaded["rustowl"] or pcall(require, "rustowl") then
  map("<leader>Rb", function() require("rustowl").toggle(buf) end, "toggle RustOwl (borrows/lifetimes)")
end
