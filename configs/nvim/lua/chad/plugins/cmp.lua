local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local kind_icons = {
	Text = "󰊄",
	Method = "m",
	Function = "󰊕",
	Constructor = "",
	Field = "",
	Variable = "󰫧",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "󰕟",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

return {
	-- cmp plugins
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			"saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",

			-- snippets
			{
				"L3MON4D3/LuaSnip",
				dependencies = "rafamadriz/friendly-snippets", -- a bunch of snippets to
				opts = { history = true, updateevents = "TextChanged,TextChangedI" },
				version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				build = "make install_jsregexp",
				config = function(_, opts)
					require("luasnip").config.set_config(opts)

					-- vscode format
					require("luasnip.loaders.from_vscode").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.g.vscode_snippets_path or "" })

					-- snipmate format
					require("luasnip.loaders.from_snipmate").load()
					require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })

					-- lua format
					require("luasnip.loaders.from_lua").load()
					require("luasnip.loaders.from_lua").lazy_load({ paths = vim.g.lua_snippets_path or "" })

					vim.api.nvim_create_autocmd("InsertLeave", {
						callback = function()
							if
								require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
								and not require("luasnip").session.jump_active
							then
								require("luasnip").unlink_current()
							end
						end,
					})
				end,
			},
			{
				"saecki/crates.nvim",
				dependencies = { "nvim-lua/plenary.nvim" },
				config = function()
					require("crates").setup()
				end,
			},
			{
				"windwp/nvim-autopairs",
				dependencies = { "hrsh7th/nvim-cmp" },
				config = function()
					local npairs = require("nvim-autopairs")
					local cmp_npairs = require("nvim-autopairs.completion.cmp")
					local cmp = require("cmp")

					npairs.setup({
						check_ts = true,
						ts_config = {
							lua = { "string", "source" },
							javascript = { "string", "template_string" },
							java = false,
						},
						disable_filetype = { "vim", "NvimTree", "TelescopePrompt", "spectre_panel" },
						fast_wrap = {
							map = "<M-e>",
							chars = { "{", "[", "(", '"', "'" },
							pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
							offset = 0, -- Offset from pattern match
							end_key = "$",
							keys = "qwertyuiopzxcvbnmasdfghjkl",
							check_comma = true,
							highlight = "PmenuSel",
							highlight_grey = "LineNr",
						},
					})

					cmp.event:on("confirm_done", cmp_npairs.on_confirm_done())
				end,
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				mapping = {
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
					["<C-e>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					}),
					-- Accept currently selected item. If none selected, `select` first item.
					-- Set `select` to `false` to only confirm explicitly selected items.
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expandable() then
							luasnip.expand()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif check_backspace() then
							fallback()
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- Kind icons
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
						-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatenates the icons with the name of the item kind
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							nvim_lua = "[NVIM_LUA]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
							crates = "[Crates]",
						})[entry.source.name]
						return vim_item
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
					{ name = "crates" },
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				window = {
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = true,
					native_menu = false,
				},
			})
		end,
	},
}
