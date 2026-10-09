local jdtls = require('jdtls')

local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local launcher_jar = vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

local os_config = mason_path .. '/config_linux' -- config_mac / config_win

-- Root directory
local root_dir = require('jdtls.setup').find_root({
  '.project',
  '.classpath',
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'mvnw',
  'gradlew',
})

if root_dir == nil then
  return
end

-- Per-project workspace
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. project_name

-- Java debug adapter from Mason
local bundles = {}

local java_debug_path =
    vim.fn.stdpath('data')
    .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'

local java_debug_bundle = vim.fn.glob(java_debug_path, true)

if java_debug_bundle ~= '' then
  table.insert(bundles, java_debug_bundle)
end

-- Optional: Java test bundles from Mason, needed for test debugging
local java_test_path =
    vim.fn.stdpath('data')
    .. '/mason/packages/java-test/extension/server/*.jar'

local java_test_bundles = vim.fn.glob(java_test_path, true, true)

if java_test_bundles then
  vim.list_extend(bundles, java_test_bundles)
end

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms3g',
    '-Xmx8g',
    '-XX:+UseG1GC',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher_jar,
    '-configuration', os_config,
    '-data', workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      configuration = {
        runtimes = {
          { name = "JavaSE-22", path = "/usr/lib/jvm/zulu-22-amd64/" },
        },
      },
      format = {
        enabled = true,
        tabSize = 4,
        insertSpaces = true,
        settings = {
          url = "/home/vignesh-22164/Eclipse_custom.xml",
          profile = "Eclipse Custom"
        }
      }
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(client, bufnr)
    -- Enable Java debugging
    jdtls.setup_dap({
      hotcodereplace = 'auto',
    })

    local java_remote_debug = require("config.java_remote_debug")

    vim.keymap.set("n", "<leader>dr", function()
      java_remote_debug.menu(root_dir)
    end, { buffer = bufnr, desc = "Java: Remote debug menu" })

    vim.keymap.set("n", "<leader>da", function()
      java_remote_debug.attach(root_dir)
    end, { buffer = bufnr, desc = "Java: Attach remote debugger" })

    vim.api.nvim_buf_create_user_command(bufnr, "JavaRemoteDebug", function()
      java_remote_debug.menu(root_dir)
    end, {
      desc = "Open Java remote debug menu",
    })

    vim.api.nvim_buf_create_user_command(bufnr, "JavaRemoteDebugAdd", function()
      java_remote_debug.add(root_dir)
    end, {
      desc = "Add Java remote debug server",
    })

    vim.api.nvim_buf_create_user_command(bufnr, "JavaRemoteDebugEdit", function()
      java_remote_debug.edit(root_dir)
    end, {
      desc = "Edit .remote-debug-servers",
    })

    -- Discover main classes for DAP
    require('jdtls.dap').setup_dap_main_class_configs()

    vim.keymap.set('n', '<leader>jt', function()
      jdtls.test_nearest_method()
    end, { buffer = bufnr, desc = 'Java: Test/debug nearest method' })

    vim.keymap.set('n', '<leader>jT', function()
      jdtls.test_class()
    end, { buffer = bufnr, desc = 'Java: Test/debug class' })

    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set("n", "<leader>jo", require("jdtls").organize_imports, { buffer = bufnr })
    vim.keymap.set("v", "<leader>jm", function()
      require("jdtls").extract_method(true)
    end, { buffer = bufnr })

    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = bufnr, desc = "Format Java file" })

    vim.keymap.set('v', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = bufnr, desc = "Format Java selection" })
  end,
}

vim.keymap.set('n', '<leader>e', function()
  local file = vim.fn.expand('%:p')
  vim.fn.jobstart({
    'dbus-send',
    '--session',
    '--dest=org.freedesktop.FileManager1',
    '--type=method_call',
    '/org/freedesktop/FileManager1',
    'org.freedesktop.FileManager1.ShowItems',
    'array:string:file://' .. file,
    'string:'
  }, { detach = true })
end, { desc = "Reveal file in file manager" })

jdtls.start_or_attach(config)
