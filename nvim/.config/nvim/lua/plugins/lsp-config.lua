return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "clangd", "gopls", "bashls", "pyright", "templ", "zls",
          "rust_analyzer" },
        handlers = {
          function(server_name)
            if server_name == "jdtls" then return end -- handled by nvim-jdtls
            require("lspconfig")[server_name].setup({})
          end,
        },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.ts_ls.setup({})

      local root_marker = vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]

      -- Java version 17 is required for jdtls
      lspconfig.clangd.setup({})
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          }
        }
      })
      lspconfig.bashls.setup({})
      lspconfig.pyright.setup({})
      lspconfig.templ.setup({
        cmd = { "templ", "lsp" },
        filetypes = { "templ" },
        root_dir = lspconfig.util.root_pattern("go.mod", ".git") or vim.loop.cwd,
        settings = {},
      })
      lspconfig.zls.setup({
        cmd = { "zls" },
        filetypes = { "zig", "zir" },
        root_dir = lspconfig.util.root_pattern("zls.json", "build.zig", ".git", "main.zig"),
        single_file_support = true,
      })

      lspconfig.rust_analyzer.setup({
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never", useParameterNames = false },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
            },
          },
        },
      })

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, {})
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, {})
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, {})
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, {})
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
      end, {})
    end
  }
}
