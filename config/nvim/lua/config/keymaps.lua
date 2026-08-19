-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mirror the managed Zed keymap (config/zed/keymap.json).

-- Insert mode: `j k` leaves insert mode (Zed `vim::NormalBefore`)
vim.keymap.set("i", "jk", "<esc>", { desc = "Leave insert mode" })

-- Scrolling: half-page then center the cursor (Zed `ctrl-d z z` / `ctrl-u z z`)
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up and center" })

-- Zed single-letter leader bindings on keys LazyVim leaves free.
-- LazyVim's two-letter equivalents remain available alongside these:
--   <leader>m -> format        (LazyVim <leader>cf)
--   <leader>k -> hover         (LazyVim K)
--   <leader>v -> split right   (LazyVim <leader>|)
--   <leader>z -> toggle zoom   (LazyVim <leader>wm)
-- Split down (Zed `space -`) is already LazyVim's default <leader>-; no keymap needed.
vim.keymap.set("n", "<leader>m", function()
  LazyVim.format({ force = true })
end, { desc = "Format (Zed space m)" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { desc = "Hover (Zed space k)" })
vim.keymap.set("n", "<leader>v", "<C-W>v", { desc = "Split Right (Zed space v)", remap = true })
Snacks.toggle.zoom():map("<leader>z", { desc = "Toggle Zoom (Zed space z)" })
