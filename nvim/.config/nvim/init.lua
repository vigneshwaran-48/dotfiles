local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 999
vim.opt["guicursor"] = ""
vim.cmd [[
   highlight Normal guibg=none
   highlight NonText guibg=none
   highlight Normal ctermbg=none
   highlight NonText ctermbg=none
]]


if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -NoProfile -Command Get-Clipboard',
      ['*'] = 'powershell.exe -NoProfile -Command Get-Clipboard',
    },
    cache_enabled = 0,
  }
end

require("vim-options")
require("lazy").setup("plugins")
