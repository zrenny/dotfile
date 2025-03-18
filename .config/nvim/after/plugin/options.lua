local options = {
  -- ufo
  foldcolumn = "1",
  foldlevel = 99,
  foldlevelstart = 99,
  foldenable = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
