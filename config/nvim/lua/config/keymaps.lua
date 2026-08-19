-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mirror the managed Zed keymap (config/zed/keymap.json):
-- `j k` leaves insert mode (Zed `vim::NormalBefore`)
vim.keymap.set("i", "jk", "<esc>", { desc = "Leave insert mode" })
