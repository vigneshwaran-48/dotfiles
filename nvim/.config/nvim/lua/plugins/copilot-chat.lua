return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
  },
  opts = {
    -- optional config
    show_folds = false,
    mappings = {
      submit_prompt = "<CR>", -- inside chat prompt
    },
  },
  cmd = "CopilotChat",
  keys = {
    { "<leader>ac", ":CopilotChat<CR>",        desc = "Copilot Chat Prompt" },
    { "<leader>ae", ":CopilotChatExplain<CR>", desc = "Explain Code" },
    { "<leader>af", ":CopilotChatFix<CR>",     mode = "v",                  desc = "Refactor selection" },
    {
      "<leader>ap",
      function()
        -- vim.ui.input is preferred over vim.fn.input for better UX and async nature
        vim.ui.input({
          prompt = "Ask Copilot: ",
          -- You can set a default value if needed, e.g., default = "Explain this code"
        }, function(input)
          -- The callback function is executed when the user presses Enter or cancels
          if input and input ~= "" then -- Check if input is not nil (user didn't cancel) and not empty
            -- When this command is executed with a visual selection active
            -- and the user command is defined with `range = true`,
            -- CopilotChat will automatically apply the command to the selected range.
            vim.cmd("CopilotChat " .. input)
          end
        end)
      end,
      mode = "v", -- Crucial: This mapping only works in visual mode
      desc = "Ask Copilot a custom question with visual selection",
    },
  }
}
