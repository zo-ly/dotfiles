return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "K", false },
        },
      },
    },
  },
  keys = {
    { "gh", vim.lsp.buf.hover, desc = "LSP Hover" },
  },
}
