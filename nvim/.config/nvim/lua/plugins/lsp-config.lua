-- LSP setup with Neovim's built-in vim.lsp.config / vim.lsp.enable (Neovim 0.11+).
-- nvim-lspconfig now only supplies the default server configs (its lsp/*.lua files);
-- the old require("lspconfig").<server>.setup() framework is deprecated.
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local servers = { "lua_ls", "ts_ls", "clangd", "bashls", "pyright", "zls", "rust_analyzer" }
      -- Mason builds gopls and templ with `go install`, so only ask for them when Go exists.
      if vim.fn.executable("go") == 1 then
        vim.list_extend(servers, { "gopls", "templ" })
      end
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        -- Every installed server is enabled automatically, except these:
        --   jdtls         started by nvim-jdtls (ftplugin/java.lua)
        --   clangd        enabled below with ue5.nvim's command
        --   rust_analyzer run by rustaceanvim (see rustacea.lua)
        automatic_enable = { exclude = { "jdtls", "clangd", "rust_analyzer" } },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      if vim.fn.has("nvim-0.11") == 0 then
        vim.notify("lsp-config.lua needs Neovim 0.11+ (vim.lsp.config)", vim.log.levels.ERROR)
        return
      end

      -- ue5.nvim's flags: LLVM's clangd, background index, no auto-inserted includes (they
      -- break UE's .generated.h ordering). Fine for non-Unreal C++ too.
      local ok_ue, ue = pcall(require, "ue")
      if ok_ue then
        vim.lsp.config("clangd", { cmd = ue.clangd_cmd() })
      end

      vim.lsp.config("gopls", {
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
      vim.lsp.config("zls", {
        root_markers = { "zls.json", "build.zig", ".git", "main.zig" },
      })

      vim.lsp.enable("clangd")
      -- Servers installed outside Mason (e.g. gopls or zls from your distro) are not
      -- enabled by mason-lspconfig, so enable the ones whose command is on PATH.
      for _, name in ipairs({ "lua_ls", "ts_ls", "bashls", "pyright", "gopls", "templ", "zls" }) do
        local cfg = vim.lsp.config[name]
        if cfg and type(cfg.cmd) == "table" and vim.fn.executable(cfg.cmd[1]) == 1 then
          vim.lsp.enable(name)
        end
      end

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
