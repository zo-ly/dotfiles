---@type MappingsTable
local M = {}

M.disabled = {
  n = {
    ["<tab>"] = "",
    ["<S-tab>"] = "",
    ["K"] = "",
    ["<Esc>"] = "",
  }
}

M.custom = {
  n = {
    [",p"] = {'"0p'},
    [",P"] = {'"0P'},
    [",,"] = {','},
    ["<leader>fx"] = { "<cmd> EslintFixAll <CR>", "eslint auto fix" },
    ["<leader>ql"] = { ":noh <CR>", "clear highlights" },
  }
}

M.lspconfig = {
  n = {
    ["gh"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "lsp hover",
    },
  }
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["K"] = {
      function()
        require("nvchad_ui.tabufline").tabuflineNext()
      end,
      "goto next buffer",
    },

    ["J"] = {
      function()
        require("nvchad_ui.tabufline").tabuflinePrev()
      end,
      "goto prev buffer",
    },

    ["t"] = {
      function ()
        require("nvchad_ui.tabufline").move_buf(1)
      end,
      "move buffer right"
    },

    ["T"] = {
      function ()
        require("nvchad_ui.tabufline").move_buf(-1)
      end,
      "move buffer left"
    },

    -- close buffer + hide terminal buffer
    ["<leader>x"] = {
      function()
        require("nvchad_ui.tabufline").close_buffer()
      end,
      "close buffer",
    },
  },
}

-- more keybinds!

return M
