local M = {}

-- local keymap = vim.nvim_buf_set_keymap
local lsp = vim.lsp.buf
local diagnostic = vim.diagnostic
-- local opts = { silent = true, noremap = true }

M.setup = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- disable virtual text
		virtual_text = false,
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	diagnostic.config(config)

	lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
		border = "rounded",
	})

	lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_highlight_document(client)
	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.documentHighlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

-- local function lsp_keymaps(bufnr)
--   keymap(bufnr, "n", "<leader>rn", lsp.rename, opts)
--   keymap(bufnr, "n", "<leader>ca", lsp.code_action, opts)
--   keymap(bufnr, "n", "gd", lsp.definition, opts)
--   keymap(bufnr, "n", "gD", lsp.declaration, opts)
--   keymap(bufnr, "n", "gi", lsp.implementation, opts)
--   keymap(bufnr, "n", "K", lsp.hover, opts)
--   keymap(bufnr, "n", "<leader>D", lsp.type_definition, opts)
--   keymap(bufnr, "n", "<C-k>", lsp.signature_help, opts)
--   keymap(bufnr, "n", "gr", lsp.references, opts)
--   keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
--   keymap(bufnr, "n", "gl", '<cmd>lua vim.diagnostic.open_float()', opts)
--   keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
--   keymap(bufnr, "n", "<leader>q", diagnostic.setloclist, opts)
--   vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])
--   -- keymap(bufnr, "n", "gr", require("telescope.builtin").lsp_references, opts )
-- end

M.on_attach = function(client, bufnr)
	if client.name == "ts_ls" then
		client.server_capabilities.documentFormattingProvider = false
	end
	-- lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
	local default_capabilities = cmp_nvim_lsp.default_capabilities()
	default_capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}
	M.capabilities = default_capabilities
end

return M
