-- Debugging. Rust uses codelldb (installed by mason); rustaceanvim finds it
-- automatically and provides `:RustLsp debuggables` (<leader>Rd).
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "mason-org/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    {
      "leoluz/nvim-dap-go",
      ft = "go",
      opts = {},
    },
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
    { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<F4>", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    {
      "<leader>B",
      function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
      desc = "Debug: Conditional Breakpoint",
    },
    { "<F6>", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    { "<F7>", function() require("dapui").open({ reset = true }) end, desc = "Debug: Reset UI" },
    { "<F8>", function() require("dapui").float_element() end, desc = "Debug: Float element" },
    { "<F9>", function() require("dapui").eval() end, desc = "Debug: Evaluate", mode = { "n", "v" } },
    { "<leader>w", function() require("dapui").open() end, desc = "Debug: Open UI" },
    { "<leader>W", function() require("dapui").close() end, desc = "Debug: Close UI" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      ensure_installed = { "delve", "codelldb" },
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
        -- Keep codelldb's generic launch configs for C/C++ etc., but not Rust:
        -- rustaceanvim generates proper cargo-aware configs for Rust.
        codelldb = function(config)
          config.filetypes = vim.tbl_filter(function(ft) return ft ~= "rust" end, config.filetypes or {})
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

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

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}
