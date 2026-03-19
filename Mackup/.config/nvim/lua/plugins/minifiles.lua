return {
  "nvim-mini/mini.files",
  keys = {
    {
      "<leader>e",
      function()
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(vim.api.nvim_buf_get_name(0), true)
        end
      end,
      desc = "Toggle mini.files (directory of current file)",
    },
    {
      "<leader>E",
      function()
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(vim.uv.cwd(), true)
        end
      end,
      desc = "Toggle mini.files (cwd)",
    },
    {
      "<leader>fm",
      function()
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(LazyVim.root(), true)
        end
      end,
      desc = "Toggle mini.files (root)",
    },
  },
  opts = {
    options = {
      use_as_default_explorer = true,
    },
  },
}
