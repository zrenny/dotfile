return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",

    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    -- Add more debuggers here
    {
      "leoluz/nvim-dap-go",
      ft = "go",
      dependencies = "mfussenegger/nvim-dap",
      config = function()
        require("dap-go").setup()
      end,
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,

      handlers = {},

      ensure_installed = {
        "delve",
      },
    })

    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })
    local function restore_keymaps()
      -- Unmap or rebind any keys

      vim.api.nvim_del_keymap("n", "B")
      vim.api.nvim_del_keymap("n", "C")
      vim.api.nvim_del_keymap("n", "D")
      vim.api.nvim_del_keymap("n", "K")
      vim.api.nvim_del_keymap("n", "O")
      vim.api.nvim_del_keymap("n", "P")
      vim.api.nvim_del_keymap("n", "R")
      vim.api.nvim_del_keymap("n", "S")
      vim.api.nvim_del_keymap("n", "a")
      vim.api.nvim_del_keymap("n", "b")
      vim.api.nvim_del_keymap("n", "c")
      vim.api.nvim_del_keymap("n", "n")
      vim.api.nvim_del_keymap("n", "o")
      vim.api.nvim_del_keymap("n", "p")
      vim.api.nvim_del_keymap("n", "r")
      vim.api.nvim_del_keymap("n", "s")
      vim.api.nvim_del_keymap("n", "u")
      vim.api.nvim_del_keymap("n", "w")
      vim.api.nvim_del_keymap("v", "p")
      print("Debug session ended and keymaps restored.")
    end

    -- Automatically restore keymaps when the debug session terminates
    dap.listeners.after["event_terminated"]["restore_keymaps"] = function()
      restore_keymaps()
    end

    dap.listeners.after["event_exited"]["restore_keymaps"] = function()
      restore_keymaps()
    end

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}
-- return {
--   {
--
-- 			"mfussenegger/nvim-dap",
--   },
--   {
--
--   },
-- 	{
-- 		"rcarriga/nvim-dap-ui",
-- 		dependencies = {
-- 			"mfussenegger/nvim-dap",
-- 			dependencies = "theHamsta/nvim-dap-virtual-text",
-- 			config = function()
-- 				local dap = require("dap")
-- 				dap.adapters.lldb = {
-- 					type = "executable",
-- 					command = "/usr/bin/lldb",
-- 					name = "lldb",
-- 				}
--
-- 				dap.configurations.cpp = {
-- 					{
-- 						name = "Launch",
-- 						type = "lldb",
-- 						request = "launch",
-- 						program = function()
-- 							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
-- 						end,
-- 						cwd = "${workspaceFolder}",
-- 						stopOnEntry = false,
-- 						args = {},
-- 					},
-- 				}
--
-- 				dap.configurations.rust = {
-- 					{
-- 						name = "Launch",
-- 						type = "lldb",
-- 						request = "launch",
-- 						program = function()
-- 							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
-- 						end,
-- 						cwd = "${workspaceFolder}",
-- 						stopOnEntry = false,
-- 						args = {},
-- 						initCommands = function()
-- 							local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))
--
-- 							local script_import = 'command script import "'
-- 								.. rustc_sysroot
-- 								.. '/lib/rustlib/etc/lldb_lookup.py"'
-- 							local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"
--
-- 							local commands = {}
-- 							local file = io.open(commands_file, "r")
-- 							if file then
-- 								for line in file:lines() do
-- 									table.insert(commands, line)
-- 								end
-- 								file:close()
-- 							end
-- 							table.insert(commands, 1, script_import)
--
-- 							return commands
-- 						end,
-- 					},
-- 				}
--
--         dap.configurations.c = dap.configurations.cpp
-- 			end,
-- 		},
--     config = function()
--       require("dapui").setup()
--     end
-- 	},
-- }
