-- Harpoon, undotree, fugitive, indent guides (previously others.lua +
-- after/plugin/keymaps.lua)
local function harpoon_list()
  return require("harpoon"):list()
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>a", function() harpoon_list():add() end, desc = "Harpoon: add file" },
      -- <leader>hr, not <leader>r: <leader>rn (rename) would make it pause
      { "<leader>hr", function() harpoon_list():remove() end, desc = "Harpoon: remove file" },
      {
        "<leader>e",
        function() require("harpoon").ui:toggle_quick_menu(harpoon_list()) end,
        desc = "Harpoon: menu",
      },
      { "<leader><F1>", function() harpoon_list():select(1) end, desc = "Harpoon: file 1" },
      { "<leader><F2>", function() harpoon_list():select(2) end, desc = "Harpoon: file 2" },
      { "<leader><F3>", function() harpoon_list():select(3) end, desc = "Harpoon: file 3" },
      { "<leader><F4>", function() harpoon_list():select(4) end, desc = "Harpoon: file 4" },
      { "<leader>hn", function() harpoon_list():next() end, desc = "Harpoon: next" },
      { "<leader>hp", function() harpoon_list():prev() end, desc = "Harpoon: prev" },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undotree" } },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = { { "<leader>git", "<cmd>Git<CR>", desc = "Fugitive" } },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("chad_fugitive", { clear = true }),
        pattern = "fugitive",
        callback = function(ev)
          local function o(desc) return { buffer = ev.buf, silent = true, desc = desc } end
          vim.keymap.set("n", "<leader>p", function() vim.cmd.Git("push") end, o("Git: push"))
          vim.keymap.set("n", "<leader>P", function() vim.cmd.Git({ "pull", "--rebase" }) end, o("Git: pull --rebase"))
          -- set upstream if the branch wasn't set up with tracking
          -- nowait: fire immediately instead of pausing for the global <leader>td
          vim.keymap.set("n", "<leader>t", "<cmd>Git push -u origin<CR>", vim.tbl_extend("force", o("Git: push -u origin"), { nowait = true }))
        end,
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = {
      scope = { show_start = false, show_end = false },
    },
  },
}
