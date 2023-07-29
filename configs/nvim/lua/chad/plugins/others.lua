return {
	"ThePrimeagen/harpoon",
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
	},
	{
		"tpope/vim-fugitive",
		cmd = "Git",
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				space_char_blankline = " ",
				show_current_context = true,
				show_current_context_start = true,
				indentLine_enabled = 1,
				filetype_exclude = {
					"help",
					"terminal",
					"lazy",
					"lspinfo",
					"TelescopePrompt",
					"TelescopeResults",
					"mason",
					"nvdash",
					"nvcheatsheet",
					"",
				},
				buftype_exclude = { "terminal" },
				show_trailing_blankline_indent = false,
				show_first_indent_level = false,
			})
		end,
	},
	{},
}
