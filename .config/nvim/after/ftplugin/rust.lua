-- Rust buffer settings + keymaps (all under <leader>R).
-- K and gra are upgraded to rustaceanvim's versions in lua/chad/lsp.lua.
-- NOTE: don't set vim.g.rustaceanvim here; that's done in plugins/rust.lua.
local buf = vim.api.nvim_get_current_buf()

vim.opt_local.colorcolumn = "100" -- rustfmt's default max_width
-- The global config adds `-` to 'iskeyword'; in Rust that makes `w`, `ciw`
-- and `*` treat `len-1` as one word.
vim.opt_local.iskeyword:remove("-")

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
map("<leader>Rj", ":RustLsp joinLines<CR>", "join selected lines", "x") -- needs the '<,'> range
map("<leader>Ru", rust("moveItem", "up"), "move item up")
map("<leader>Rn", rust("moveItem", "down"), "move item down")
map("<leader>Rh", rust("hover", "range"), "hover range (type of selection)", "x")
map("<leader>Rw", rust("reloadWorkspace"), "reload workspace")

-- Miri: runs code in an interpreter that catches undefined behaviour in
-- `unsafe` code (out-of-bounds reads, use-after-free, data races, ...).
-- Needs the nightly toolchain with the miri component (see install.sh).
local miri_ok = false
local function miri(args, desc)
  return function()
    if not miri_ok then
      local r = vim.system({ "cargo", "+nightly", "miri", "--version" }, { text = true }):wait()
      if r.code ~= 0 then
        vim.notify("Miri isn't installed: run `rustup toolchain install nightly --component miri,rust-src`",
          vim.log.levels.WARN)
        return
      end
      miri_ok = true
    end
    local cmd = vim.list_extend({ "cargo", "+nightly", "miri" }, args())
    local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
    vim.cmd("botright 15split | enew")
    vim.bo.bufhidden = "wipe"
    vim.fn.jobstart(cmd, { term = true, cwd = cwd })
    vim.cmd("normal! G") -- follow the output
    vim.notify("Miri: " .. desc, vim.log.levels.INFO)
  end
end

-- Name of the function around the cursor (used as the test filter).
local function fn_under_cursor()
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
  while ok and node do
    if node:type() == "function_item" then
      local name = node:field("name")[1]
      return name and vim.treesitter.get_node_text(name, buf)
    end
    node = node:parent()
  end
end

map("<leader>Rit", miri(function()
  local name = fn_under_cursor()
  -- not inside a function: run every test
  return name and { "test", "--", name } or { "test" }
end, "test under cursor"), "Miri: test under cursor")
map("<leader>RiT", miri(function() return { "test" } end, "all tests"), "Miri: all tests")
map("<leader>Rir", miri(function() return { "run" } end, "run"), "Miri: cargo run")

-- RustOwl ownership/lifetime highlighting (only if the plugin is loaded)
if package.loaded["rustowl"] or pcall(require, "rustowl") then
  map("<leader>Rb", function() require("rustowl").toggle(buf) end, "toggle RustOwl (borrows/lifetimes)")
end
