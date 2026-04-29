local jdtls = require('jdtls')

local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local launcher_jar = vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

local os_config = mason_path .. '/config_linux' -- config_mac / config_win

-- Per-project workspace (indexes, caches)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. project_name

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms3g',
    '-Xmx8g',       -- increase from default, give it more heap
    '-XX:+UseG1GC', -- better garbage collector
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher_jar,
    '-configuration', os_config,
    '-data', workspace_dir,
  },

  -- Look for .project file first
  root_dir = require('jdtls.setup').find_root({ '.project', '.classpath' }),

  settings = {
    java = {
      configuration = {
        runtimes = {
          { name = "JavaSE-22", path = "/usr/lib/jvm/zulu-22-amd64/" },
        },
      },
      format = {
        enabled = true,
        settings = {
          url = "/home/vignesh-22164/Eclipse_custom.xml"
        }
      }
    },
  },
}

vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { buffer = 0, desc = "Format Java file" })

vim.keymap.set('v', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { buffer = 0, desc = "Format Java selection" })

vim.keymap.set('n', '<leader>e', function()
  local file = vim.fn.expand('%:p')
  -- Works with Nautilus, Nemo, Dolphin, Thunar
  vim.fn.jobstart({ 'dbus-send', '--session', '--dest=org.freedesktop.FileManager1',
    '--type=method_call', '/org/freedesktop/FileManager1',
    'org.freedesktop.FileManager1.ShowItems',
    'array:string:file://' .. file, 'string:' }, { detach = true })
end, { desc = "Reveal file in file manager" })


jdtls.start_or_attach(config)
