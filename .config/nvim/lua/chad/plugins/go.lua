return {
  "ray-x/go.nvim",
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup()
    local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        require("go.format").goimports()
      end,
      group = format_sync_grp,
    })
    -- Lua function to run fuzz tests sequentially
    local function run_fuzz_tests(opts)
      -- Set fuzztime (default is 10s if not provided)
      local fuzztime = opts.fargs[1] or "10s"

      -- Check if verbose mode is enabled
      local verbose = opts.fargs[2] == "verbose" and "-v" or ""

      -- Run a shell command to find all Go test files in the current working directory
      -- and extract fuzz test functions
      local handle = io.popen("grep -r -h 'func Fuzz' . | grep -o 'Fuzz[A-Za-z0-9]*' | sort | uniq")
      local result = handle:read("*a")
      handle:close()

      -- Split the result into individual fuzz test names
      local fuzz_tests = {}
      for fuzz_test in string.gmatch(result, "[%w_]+") do
        table.insert(fuzz_tests, fuzz_test)
      end

      -- If no fuzz tests are found, print a message
      if #fuzz_tests == 0 then
        print("No fuzz tests found!")
        return
      end

      -- Run each fuzz test one by one
      for _, fuzz_test in ipairs(fuzz_tests) do
        print("Running fuzz test: " .. fuzz_test)
        -- Execute the Go fuzz test with the provided fuzztime and verbose flag
        vim.cmd("!go test -fuzz=" .. fuzz_test .. " -fuzztime=" .. fuzztime .. " " .. verbose .. " ./...")
      end

      print("All fuzz tests completed.")
    end

    -- Create a custom command to run the fuzz tests
    vim.api.nvim_create_user_command("GoTestAllFuzz", run_fuzz_tests, { nargs = "*" })
  end,
  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  build = ':lua require("go.install").update_all_sync()',
}
