-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "Y", '"*y')
vim.keymap.set("n", "H", "H")
vim.keymap.set("n", "L", "L")
vim.keymap.set("n", "J", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "K", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
