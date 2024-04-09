-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require('gitsigns').setup()

require("nvim-tree").setup()

require("bufferline").setup({
  options = {
    offsets = {
      {
        filetype = "NvimTree",
        highlight = "Directory",
        text_align = "left",
        text = function()
          return vim.fn.getcwd() or "File Explorer"
        end,
      },
      {
        filetype = "DiffviewFiles",
        highlight = "Directory",
        text_align = "left",
        text = function()
          return vim.fn.getcwd() or "Git Diff"
        end,
      }
    }
  }
})

require('lualine').setup({
  options = {
    section_separators = '',
    component_separators = { left = '|', right = '|' }
  }
})

require('Comment').setup()

