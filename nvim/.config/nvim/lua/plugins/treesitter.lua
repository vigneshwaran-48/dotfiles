return {
  "nvim-treesitter/nvim-treesitter",
  -- The default branch is now "main", a rewrite without nvim-treesitter.configs and
  -- without the API telescope 0.1.x uses for previews. Stay on master.
  branch = "master",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      auto_install = true,
      indent = { enable  = true },
      -- JSP is not a filetype treesitter knows about, so auto_install never
      -- fetches these. nvim-jsp needs all three.
      ensure_installed = { "embedded_template", "java", "html" },
    })
  end
}
