-- Unreal Engine 5: clangd setup, UBT builds, codelldb debugging.
-- https://github.com/vigneshwaran-48/ue5.nvim
-- Only does anything inside a folder with a .uproject, so it's safe on every machine.
return {
  "vigneshwaran-48/ue5.nvim",
  lazy = false,
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {},
  keys = {
    { "<leader>ub", "<cmd>UE build<cr>",         desc = "UE: build" },
    { "<leader>ut", "<cmd>UE target<cr>",        desc = "UE: pick target/config" },
    { "<leader>ud", "<cmd>UE debug<cr>",         desc = "UE: build + debug" },
    { "<leader>ua", "<cmd>UE attach<cr>",        desc = "UE: attach to editor" },
    { "<leader>ue", "<cmd>UE editor<cr>",        desc = "UE: build + open editor" },
    { "<leader>uE", "<cmd>UE editornobuild<cr>", desc = "UE: open editor (no build)" },
    { "<leader>uc", "<cmd>UE compiledb<cr>",     desc = "UE: regenerate compile_commands.json" },
    { "<leader>ul", "<cmd>UE log<cr>",           desc = "UE: build log" },
    { "<leader>ux", "<cmd>UE cancel<cr>",        desc = "UE: cancel build" },
    { "<leader>uq", "<cmd>UE close<cr>",         desc = "UE: close debug/log/quickfix windows" },
  },
}
