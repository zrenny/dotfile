-- Plugin-independent LSP setup: diagnostics, shared client config, and
-- buffer-local keymaps applied on LspAttach. Server-specific settings live in
-- after/lsp/<server>.lua (merged automatically by vim.lsp.config).
local M = {}

local function setup_diagnostics()
  -- Nerd Font glyphs (same as before), written as escapes so editors can't mangle them
  local icons = { ERROR = "\u{f057}", WARN = "\u{f071}", HINT = "\u{f05a}", INFO = "\u{f059}" }
  vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.ERROR,
        [vim.diagnostic.severity.WARN] = icons.WARN,
        [vim.diagnostic.severity.HINT] = icons.HINT,
        [vim.diagnostic.severity.INFO] = icons.INFO,
      },
    },
    float = {
      focusable = false,
      style = "minimal",
      source = true,
      header = "",
      prefix = "",
    },
    -- Show the diagnostic float after [d / ]d (Neovim's built-in mappings).
    -- (`float = true` in vim.diagnostic.jump() is deprecated in 0.12.)
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
      end,
    },
  })
end

local function client_capabilities()
  local caps = {
    textDocument = {
      -- nvim-ufo uses LSP folding ranges
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
    },
  }
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    caps = vim.tbl_deep_extend("force", caps, cmp_lsp.default_capabilities())
  end
  return caps
end

---@param buf integer
---@param client vim.lsp.Client
local function on_attach(buf, client)
  local function map(mode, lhs, rhs, desc, extra)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, silent = true, desc = desc }, extra or {}))
  end
  local lsp = vim.lsp.buf

  -- Neovim already maps these whenever an LSP client is attached (0.12+), so
  -- they aren't repeated here (`:help lsp-defaults`):
  --   grn rename            gra code action        grr references
  --   gri implementation    grt type definition    grx run code lens
  --   gO  document symbols  K   hover              <C-s> signature help (insert)
  -- Only keys Neovim doesn't provide are added below. (No `gr` map: it would
  -- make every gr* key wait for 'timeoutlen'.)
  map("n", "gD", lsp.declaration, "Go to declaration")
  map("n", "gd", lsp.definition, "Go to definition")
  map("n", "gs", lsp.signature_help, "Signature help")
  -- No explicit lsp_format here, so per-filetype settings apply (Rust prefers
  -- rust-analyzer); everything else falls back to LSP via default_format_opts.
  -- <leader>fm, not <leader>f: <leader>ff/fb/fs would make it pause 'timeoutlen'
  map("n", "<leader>fm", function() require("conform").format({ async = true }) end, "Format buffer")
  map("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
  end, "Toggle inlay hints")

  -- In Rust buffers, K and gra are replaced with rustaceanvim's richer versions.
  -- Keyed on filetype (not client) so a second client attaching later (rustowl,
  -- typos_lsp, ...) can't clobber them.
  if vim.bo[buf].filetype == "rust" then
    -- :RustLsp only exists while rust-analyzer is running; fall back otherwise
    local function rust_or(fallback, ...)
      local args = { ... }
      return function()
        if vim.fn.exists(":RustLsp") == 2 then
          vim.cmd.RustLsp(args)
        else
          fallback()
        end
      end
    end
    map("n", "K", rust_or(lsp.hover, "hover", "actions"), "Rust hover actions")
    -- Neovim's own gra can't show rust-analyzer's grouped code actions
    map({ "n", "x" }, "gra", rust_or(lsp.code_action, "codeAction"), "Rust code action (grouped)")
  end

  if client:supports_method("textDocument/inlayHint", buf) then
    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
  end

  -- Code lenses (e.g. "▶ Run | Debug" above Rust mains/tests, gopls lenses);
  -- run the one under the cursor with grx
  if client:supports_method("textDocument/codeLens", buf) then
    vim.lsp.codelens.enable(true, { bufnr = buf })
  end

  local highlight = "textDocument/documentHighlight"
  if client:supports_method(highlight, buf) then
    local hl_group = vim.api.nvim_create_augroup("chad_lsp_highlight_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_group,
      buffer = buf,
      callback = function() vim.lsp.buf.document_highlight() end,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = hl_group,
      buffer = buf,
      callback = function() vim.lsp.util.buf_clear_references(buf) end,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
      group = hl_group,
      buffer = buf,
      callback = function(ev)
        -- Only tear down once no remaining client can highlight (e.g. typos_lsp
        -- detaching must not switch it off while rust-analyzer is still attached)
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf, method = highlight })) do
          if c.id ~= ev.data.client_id then
            return
          end
        end
        vim.lsp.util.buf_clear_references(buf)
        pcall(vim.api.nvim_del_augroup_by_id, hl_group)
      end,
    })
  end
end

function M.setup()
  setup_diagnostics()

  -- [d / ]d are Neovim defaults (they use the `jump` config above)
  vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, { desc = "Line diagnostics" })
  vim.keymap.set("n", "<leader>sl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
  vim.keymap.set("n", "<leader>sc", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("chad_lsp_attach", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then
        on_attach(ev.buf, client)
      end
    end,
  })
end

-- Called from the lspconfig spec once nvim-cmp is on the runtimepath.
function M.configure_clients()
  -- Applies to every client, including rust-analyzer (rustaceanvim merges
  -- vim.lsp.config["*"] into its own client config).
  vim.lsp.config("*", { capabilities = client_capabilities() })
end

return M
