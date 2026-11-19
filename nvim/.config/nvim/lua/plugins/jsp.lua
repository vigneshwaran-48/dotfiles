return {
  dir = vim.fn.expand("~/nvim-jsp"),
  name = "nvim-jsp",
  -- Local plugin that only exists on the Linux machine.
  cond = vim.uv.fs_stat(vim.fn.expand("~/nvim-jsp")) ~= nil,
  ft = { "jsp" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },

  -- The filetype has to be known before `ft = { "jsp" }` can trigger the load,
  -- so registration happens here rather than in the plugin's ftdetect/.
  init = function()
    vim.filetype.add({
      extension = {
        jsp = "jsp",
        jspf = "jsp",
        jspx = "jsp",
        tag = "jsp",
        tagf = "jsp",
        tagx = "jsp",
      },
    })
  end,

  opts = {
    search_roots = { "~/Office/ZohoWorkspace" },
  },
}
