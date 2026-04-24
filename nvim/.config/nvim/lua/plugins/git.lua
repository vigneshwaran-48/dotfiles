return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require('gitsigns').setup {
        signs                        = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged                 = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable          = true,
        signcolumn                   = true,
        numhl                        = false,
        linehl                       = false,
        word_diff                    = false,
        watch_gitdir                 = {
          follow_files = true
        },
        auto_attach                  = true,
        attach_to_untracked          = false,
        current_line_blame           = true,
        current_line_blame_opts      = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,
        max_file_length              = 40000,
        preview_config               = {
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      }

      -- Gitsigns keymaps
      vim.keymap.set('n', '<leader>tb', ':Gitsigns toggle_current_line_blame<CR>', { silent = true, desc = "Toggle inline blame" })
      vim.keymap.set('n', '<leader>gb', ':Gitsigns blame<CR>', { silent = true, desc = "Full file blame" })
      vim.keymap.set('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', { silent = true, desc = "Preview hunk" })
      vim.keymap.set('n', '<leader>hs', ':Gitsigns stage_hunk<CR>', { silent = true, desc = "Stage hunk" })
      vim.keymap.set('n', '<leader>hr', ':Gitsigns reset_hunk<CR>', { silent = true, desc = "Reset hunk" })
      vim.keymap.set('n', ']c', ':Gitsigns next_hunk<CR>', { silent = true, desc = "Next hunk" })
      vim.keymap.set('n', '[c', ':Gitsigns prev_hunk<CR>', { silent = true, desc = "Prev hunk" })
    end
  },
  {
    "tpope/vim-fugitive",
    cmd = "Git",  -- lazy loads only when you use :Git
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },  -- lazy loads on command
    config = function()
      require("diffview").setup({})
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { silent = true, desc = "Open diff view" })
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { silent = true, desc = "File history" })
      vim.keymap.set('n', '<leader>gH', ':DiffviewFileHistory<CR>', { silent = true, desc = "Branch history" })
      vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { silent = true, desc = "Close diff view" })
    end
  },
}
