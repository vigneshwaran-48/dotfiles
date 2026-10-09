return {
  "nvim-treesitter/nvim-treesitter", 
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
