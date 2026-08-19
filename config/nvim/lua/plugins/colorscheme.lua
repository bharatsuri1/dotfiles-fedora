return {
  -- Vesper theme, matching the managed Zed/Alacritty/Quickshell palette.
  -- Port of the VS Code Vesper theme (raunofreiberg/vesper).
  { "datsfilipe/vesper.nvim", priority = 1000 },

  -- Configure LazyVim to load Vesper
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vesper",
    },
  },
}
