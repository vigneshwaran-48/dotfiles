return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            horizontal = {
              width = 0.90,
              preview_width = 0.5,
            },
          },
          path_display = function(opts, path)
            if not path:match("%.java$") then
              return path
            end
            local tail = vim.fn.fnamemodify(path, ":t")
            local parent = vim.fn.fnamemodify(path, ":h:t")
            return string.format("%s  (%s)", tail, parent)
          end,
        },
        pickers = {
          lsp_references = { fname_width = 80 },
          lsp_implementations = { fname_width = 80 },
          lsp_definitions = { fname_width = 80 },
          lsp_type_definitions = { fname_width = 80 },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          }
        }
      })
      require("telescope").load_extension("ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', 'gi', builtin.lsp_implementations, {})
      vim.keymap.set('n', 'gr', builtin.lsp_references, {})
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
      vim.keymap.set('n', '<space>D', builtin.lsp_type_definitions, {})
    end
  },
}
