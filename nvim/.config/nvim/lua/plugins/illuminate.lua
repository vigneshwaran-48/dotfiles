return {
  "RRethy/vim-illuminate",
  config = function()
    require("illuminate").configure({
      delay = 200,
      providers = { "lsp", "treesitter", "regex" },
    })
  end,
}
