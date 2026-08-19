-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Mirror the managed Zed settings (config/zed/settings.json):
-- substitute replaces all matches in a line by default (Zed `gdefault`)
vim.opt.gdefault = true
-- keep a 10-line scroll margin (Zed `vertical_scroll_margin`)
vim.opt.scrolloff = 10

-- Font is inherited from the terminal (Alacritty uses JetBrainsMono Nerd Font).
-- This only affects GUI clients such as Neovide.
vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
