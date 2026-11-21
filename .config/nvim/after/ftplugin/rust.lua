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
map("<leader>Ro", rust("openDocs"), "open docs for symbol (local if built, else docs.rs)")
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
local function miri_available()
  if miri_ok then return true end
  -- RUSTUP_AUTO_INSTALL=0: without it, a missing nightly makes rustup
  -- download the whole toolchain right here and freeze Neovim meanwhile.
  local r = vim.system({ "cargo", "+nightly", "miri", "--version" },
    { text = true, env = { RUSTUP_AUTO_INSTALL = "0" } }):wait(10000)
  if r.code ~= 0 then
    vim.notify("Miri isn't installed: run `rustup toolchain install nightly --allow-downgrade "
      .. "--component miri,rust-src` (or rerun install.sh)", vim.log.levels.WARN)
    return false
  end
  miri_ok = true
  return true
end

local function miri(args, desc)
  return function()
    if not miri_available() then return end
    local cmd = vim.list_extend({ "cargo", "+nightly", "miri" }, args())
    local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
    require("chad.runner").run(cmd, { cwd = cwd }) -- shared split, see chad/runner.lua
    vim.notify("Miri: " .. desc, vim.log.levels.INFO)
  end
end

-- The same Miri run under both aliasing models at once, side by side:
-- Stacked Borrows (Miri's default) on the left, Tree Borrows on the right.
-- Other flags in your $MIRIFLAGS (e.g. -Zmiri-disable-isolation) apply to both.
local function miri_both(args, desc)
  return function()
    if not miri_available() then return end
    local cmd = vim.list_extend({ "cargo", "+nightly", "miri" }, args())
    local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
    -- Split your MIRIFLAGS per model (whole flags, not text):
    -- left: without Tree Borrows flags, so it really is the default model;
    -- right: -Zmiri-tree-borrows first, then your other flags (incl. any
    -- -Zmiri-tree-borrows-* options). -Zmiri-disable-stacked-borrows turns
    -- aliasing checks off entirely, which would defeat the comparison: dropped.
    local sb_flags, tb_flags = {}, { "-Zmiri-tree-borrows" }
    for _, f in ipairs(vim.split(vim.env.MIRIFLAGS or "", "%s+", { trimempty = true })) do
      if f == "-Zmiri-disable-stacked-borrows" or f == "-Zmiri-tree-borrows" then
        -- skip (the latter is already first in tb_flags)
      elseif vim.startswith(f, "-Zmiri-tree-borrows") then
        table.insert(tb_flags, f)
      else
        table.insert(sb_flags, f)
        table.insert(tb_flags, f)
      end
    end
    local result = {}
    local function finished(model)
      return function(code)
        result[model] = code == 0 and "ok" or "FAILED"
        if result.sb and result.tb then
          vim.notify(("Miri %s: Stacked Borrows %s, Tree Borrows %s"):format(desc, result.sb, result.tb),
            (result.sb == "ok" and result.tb == "ok") and vim.log.levels.INFO or vim.log.levels.WARN)
        end
      end
    end
    require("chad.runner").run_panes({
      { cmd = cmd, cwd = cwd, env = { MIRIFLAGS = table.concat(sb_flags, " ") },
        title = "Miri: Stacked Borrows (default)", on_exit = finished("sb") },
      { cmd = cmd, cwd = cwd, env = { MIRIFLAGS = table.concat(tb_flags, " ") },
        title = "Miri: Tree Borrows", on_exit = finished("tb") },
    })
    vim.notify("Miri, both aliasing models: " .. desc, vim.log.levels.INFO)
  end
end

-- Does this fn have a test attribute? (#[test], #[tokio::test], #[rstest], ...)
local function is_test_fn(fn)
  local sib = fn:prev_named_sibling()
  while sib and (sib:type() == "attribute_item" or sib:type():match("comment$")) do
    if sib:type() == "attribute_item" and vim.treesitter.get_node_text(sib, buf):match("test") then
      return true
    end
    sib = sib:prev_named_sibling()
  end
  return false
end

-- Test filter for the #[test] fn around the cursor, e.g. "tests::parses_empty"
-- (inline `mod` names included, so a short fn name matches fewer other tests).
-- nil when the cursor isn't inside a test function.
local function test_under_cursor()
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
  if not ok then return nil end
  while node and node:type() ~= "function_item" do node = node:parent() end
  if not node or not is_test_fn(node) then return nil end
  local parts = { vim.treesitter.get_node_text(node:field("name")[1], buf) }
  local p = node:parent()
  while p do
    if p:type() == "mod_item" then
      table.insert(parts, 1, vim.treesitter.get_node_text(p:field("name")[1], buf))
    end
    p = p:parent()
  end
  return table.concat(parts, "::")
end

local function miri_test_args()
  local name = test_under_cursor()
  -- not inside a test function: run every test
  return name and { "test", "--", name } or { "test" }
end
map("<leader>Rit", miri(miri_test_args, "test under cursor"), "Miri: test under cursor")
map("<leader>RiT", miri(function() return { "test" } end, "all tests"), "Miri: all tests")
map("<leader>Rib", miri_both(miri_test_args, "test under cursor"),
  "Miri: test under cursor, both models (Stacked + Tree Borrows)")
map("<leader>RiB", miri_both(function() return { "test" } end, "all tests"),
  "Miri: all tests, both models (Stacked + Tree Borrows)")
map("<leader>Rir", miri(function() return { "run" } end, "run"), "Miri: cargo run")

-- Tests with their printed output (println!, dbg!) shown live, in the
-- shared output split. (<leader>Rt runs single tests in the background,
-- which only reports pass/fail.)

-- The nearest test as rust-analyzer sees it: the test fn under the cursor
-- (run with --exact), else the innermost test module. Calls back with nil
-- if rust-analyzer isn't running or the cursor isn't in a test.
local function nearest_test_runnable(cb)
  local client = vim.lsp.get_clients({ bufnr = buf, name = "rust-analyzer" })[1]
  if not client then return cb(nil) end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request("experimental/runnables", params, function(err, res)
    if err or type(res) ~= "table" then return cb(nil) end
    local fn_test, mod_test
    for _, r in ipairs(res) do
      local label = type(r.label) == "string" and r.label or ""
      -- skip "test x + UPDATE_EXPECT"-style entries: they rewrite snapshots
      if r.kind == "cargo" and not label:find(" + ", 1, true) then
        if not fn_test and (vim.startswith(label, "test ") or vim.startswith(label, "doctest ")) then
          fn_test = r
        elseif vim.startswith(label, "test-mod ") then
          -- innermost module = longest path
          if not mod_test or #label > #mod_test.label then mod_test = r end
        end
      end
    end
    cb(fn_test or mod_test)
  end, buf)
end

local function with_output(args)
  args = vim.list_extend({}, args)
  if not vim.tbl_contains(args, "--nocapture") and not vim.tbl_contains(args, "--no-capture") then
    table.insert(args, "--nocapture")
  end
  return args
end

local function run_with_output(cmd, opts, what)
  local runner = require("chad.runner")
  runner.last_test_with_output = { cmd = cmd, opts = opts, what = what }
  runner.run(cmd, opts)
  vim.notify("Tests with output: " .. what, vim.log.levels.INFO)
end

map("<leader>Rvt", function()
  local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
  nearest_test_runnable(function(r)
    if r then
      local a = r.args or {}
      local args = vim.list_extend(vim.list_extend({}, a.cargoArgs or {}), a.cargoExtraArgs or {})
      table.insert(args, "--")
      vim.list_extend(args, with_output(a.executableArgs or {}))
      local env = type(a.environment) == "table" and next(a.environment) and a.environment or nil
      local prog = type(a.overrideCargo) == "string" and a.overrideCargo or "cargo"
      return run_with_output(vim.list_extend({ prog }, args),
        { cwd = a.cwd or a.workspaceRoot or cwd, env = env }, r.label)
    end
    -- no rust-analyzer: filter by the #[test] fn's name, else run everything
    local name = test_under_cursor()
    local args = name and { "test", "--", name, "--nocapture" } or { "test", "--", "--nocapture" }
    run_with_output(vim.list_extend({ "cargo" }, args), { cwd = cwd }, name or "all tests")
  end)
end, "test under cursor, with output")

map("<leader>RvT", function()
  local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
  -- one at a time, so the output of different tests doesn't interleave
  run_with_output({ "cargo", "test", "--", "--nocapture", "--test-threads=1" }, { cwd = cwd },
    "all tests (one at a time)")
end, "all tests, with output (one at a time)")

map("<leader>Rvr", function()
  local last = require("chad.runner").last_test_with_output
  if not last then
    return vim.notify("No test run with output yet (<leader>Rvt / <leader>RvT)", vim.log.levels.WARN)
  end
  run_with_output(last.cmd, last.opts, last.what)
end, "rerun last test with output")

-- Docs for your own code: build them with `cargo doc` (private items too),
-- then open the page for the symbol under the cursor in the browser.
-- Why not just <leader>Ro: for your own crates rust-analyzer's fallback is a
-- made-up docs.rs link, so without local docs it opens the wrong page.

-- Doc folder names (crate targets, `-` -> `_`) of the workspace, plus where
-- `cargo doc` writes. nil if `cargo metadata` fails.
local function cargo_docs_info(cwd)
  local r = vim.system({ "cargo", "metadata", "--no-deps", "--format-version", "1" },
    { cwd = cwd, text = true }):wait(15000)
  if r.code ~= 0 then return nil end
  local ok, meta = pcall(vim.json.decode, r.stdout)
  if not ok then return nil end
  local doc_dir = vim.fs.joinpath(meta.target_directory, "doc")
  local own, index = {}, nil
  -- real paths: cargo reports resolved paths, the buffer may be via a symlink
  local function real(p) return vim.uv.fs_realpath(p) or vim.fs.normalize(p) end
  local manifest = real(vim.fs.joinpath(cwd, "Cargo.toml"))
  for _, pkg in ipairs(meta.packages) do
    local mine = real(pkg.manifest_path) == manifest
    -- rustdoc documents the library if there is one, otherwise the binaries
    for _, want_lib in ipairs({ true, false }) do
      for _, t in ipairs(pkg.targets) do
        local is_lib = vim.iter(t.kind):any(function(k) return k:match("lib") or k == "proc-macro" end)
        if is_lib == want_lib and (is_lib or vim.tbl_contains(t.kind, "bin")) then
          local name = t.name:gsub("-", "_")
          own[name] = true
          local page = vim.fs.joinpath(doc_dir, name, "index.html")
          if mine and not index and vim.uv.fs_stat(page) then index = page end
        end
      end
    end
  end
  return { doc_dir = doc_dir, own = own, index = index }
end

local function open_docs_for_cursor(win, cwd)
  local info = cargo_docs_info(cwd)
  local function front_page()
    if info and info.index then
      vim.ui.open(info.index)
    else
      vim.notify("Docs were built, but no front page was found under target/doc", vim.log.levels.WARN)
    end
  end
  local client = vim.lsp.get_clients({ bufnr = buf, name = "rust-analyzer" })[1]
  if not client then return front_page() end
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  client:request("experimental/externalDocs", params, function(_, res)
    -- JSON null arrives as vim.NIL (truthy), so keep only real strings
    local function str(v) return type(v) == "string" and v or nil end
    local loc = type(res) == "table" and str(res["local"]) or nil
    local web = type(res) == "table" and str(res.web) or str(res)
    if loc and vim.uv.fs_stat(vim.uri_to_fname(loc)) then
      -- rust-analyzer sends `file:////abs/path...#method.x`; reopen as a clean
      -- file:/// URL, keeping the #anchor that scrolls to methods/fields
      return vim.ui.open(vim.uri_from_fname(vim.uri_to_fname(loc)) .. (loc:match("#.*$") or ""))
    end
    -- `.../target/doc/<crate>/...`: a page of your own code that rustdoc
    -- didn't generate (e.g. an item inside a fn): show the crate front page
    local crate = loc and info and vim.uri_to_fname(loc):match("/doc/([^/]+)/")
    if not web or (crate and info.own[crate]) then return front_page() end
    -- std / registry dependencies (not built: --no-deps keeps it fast).
    -- Limit: a path dependency outside your workspace isn't built either, and
    -- rust-analyzer's link for it is a made-up docs.rs one.
    vim.ui.open(web)
  end, buf)
end

map("<leader>RO", function()
  local win = vim.api.nvim_get_current_win()
  local cwd = vim.fs.root(buf, "Cargo.toml") or vim.fn.getcwd()
  local runner = require("chad.runner")
  -- --workspace: symbols from sibling crates in the same workspace get pages too
  runner.run({ "cargo", "doc", "--workspace", "--no-deps", "--document-private-items" }, {
    cwd = cwd,
    on_exit = function(code)
      if code ~= 0 then
        vim.notify("cargo doc failed (output is in the split below)", vim.log.levels.ERROR)
        return
      end
      runner.close() -- nothing to read when it worked
      if vim.api.nvim_win_is_valid(win) then open_docs_for_cursor(win, cwd) end
    end,
  })
end, "build my docs (cargo doc) + open symbol")

map("<leader>Rq", function() require("chad.runner").close() end, "close the output split")

-- RustOwl ownership/lifetime highlighting (only if the plugin is loaded)
if package.loaded["rustowl"] or pcall(require, "rustowl") then
  map("<leader>Rb", function() require("rustowl").toggle(buf) end, "toggle RustOwl (borrows/lifetimes)")
end
