return {
  "m4xshen/smartcolumn.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    colorcolumn = "120",
    scope = "window",
    editorconfig = true,

    disabled_filetypes = {
      "help",
      "text",
      "markdown",
      "NvimTree",
      "neo-tree",
      "lazy",
      "mason",
      "checkhealth",
      "lspinfo",
      "Trouble",
      "gitcommit",
    },
  },
}
