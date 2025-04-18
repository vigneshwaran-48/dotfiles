return {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('flutter-tools').setup({
      flutter_lookup_cmd = "/snap/bin/flutter",
      lsp = {
        cmd = { "/snap/bin/dart", "language-server", "--protocol=lsp" }
      }
    })
  end,
}
