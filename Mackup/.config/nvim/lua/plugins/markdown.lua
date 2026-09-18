return {
  -- markdown-preview.nvim is unmaintained upstream (last commit 2023-10)
  { "iamcco/markdown-preview.nvim", enabled = false },
  -- render-markdown and markview both render in-buffer; keep only one
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>m", group = "markdown", icon = "" } } },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- plugin handles its own lazy-loading
    keys = {
      { "<leader>ms", "<cmd>Markview splitToggle<cr>", ft = "markdown", desc = "Toggle Split Preview" },
      { "<leader>mm", "<cmd>Markview toggle<cr>", ft = "markdown", desc = "Toggle Markview" },
      { "<leader>um", "<cmd>Markview toggle<cr>", ft = "markdown", desc = "Toggle Markview" },
    },
  },
  {
    "brianhuster/live-preview.nvim",
    keys = {
      {
        "<leader>mp",
        function()
          local lp = require("livepreview")
          vim.cmd(lp.is_running() and "LivePreview close" or "LivePreview start")
        end,
        ft = "markdown",
        desc = "Toggle Browser Preview",
      },
    },
    config = function()
      require("livepreview.config").set({ picker = "snacks.picker" })
    end,
  },
}
