-- Vesper colorscheme for Neovim.
--
-- Self-contained port of the managed Vesper identity. The palette mirrors
-- config/zed/themes/vesper.json, which is shared with Zed, Alacritty, and
-- Quickshell. No third-party colorscheme plugin is used.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "vesper"
vim.o.termguicolors = true

-- Palette (from config/zed/themes/vesper.json)
local c = {
  bg = "#101010",
  bg_alt = "#161616",
  bg_active = "#202020",
  border = "#2A2A2A",
  border_variant = "#3A3A3A",
  fg = "#FFFFFF",
  muted = "#A0A0A0",
  disabled = "#7E7E7E",
  accent = "#FFC799",
  red = "#FF8080",
  salmon = "#F5A191",
  green = "#90B99F",
  mint = "#99FFE4",
  yellow = "#E6B99D",
  pink = "#E29ECA",
  magenta = "#EA83A5",
  purple = "#ACA1CF",
  purple_light = "#B9AEDA",
  param = "#d2a6ff",
}

local function set_hl(groups)
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

-- Terminal ANSI palette
vim.g.terminal_color_0 = c.bg
vim.g.terminal_color_1 = c.salmon
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.purple
vim.g.terminal_color_5 = c.pink
vim.g.terminal_color_6 = c.magenta
vim.g.terminal_color_7 = c.muted
vim.g.terminal_color_8 = c.disabled
vim.g.terminal_color_9 = c.red
vim.g.terminal_color_10 = c.mint
vim.g.terminal_color_11 = c.accent
vim.g.terminal_color_12 = c.purple_light
vim.g.terminal_color_13 = "#ECAAD6"
vim.g.terminal_color_14 = "#F591B2"
vim.g.terminal_color_15 = c.fg

-- Base UI
set_hl({
  Normal = { fg = c.fg, bg = c.bg },
  NormalFloat = { bg = c.bg_alt },
  NormalNC = { link = "Normal" },
  Cursor = { fg = c.bg, bg = c.accent },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  TermCursor = { link = "Cursor" },
  TermCursorNC = { link = "Cursor" },
  Visual = { bg = "#4A3A30" },
  VisualNOS = { link = "Visual" },
  CursorLine = { bg = "#191919" },
  CursorColumn = { link = "CursorLine" },
  ColorColumn = { bg = c.bg_alt },
  LineNr = { fg = c.disabled },
  CursorLineNr = { fg = c.muted },
  SignColumn = { fg = c.disabled, bg = c.bg },
  FoldColumn = { link = "SignColumn" },
  Folded = { fg = c.muted, bg = c.bg_alt },
  EndOfBuffer = { fg = c.bg },
  NonText = { fg = c.disabled },
  Whitespace = { fg = c.disabled },
  SpecialKey = { fg = c.disabled },
  Conceal = { fg = c.disabled },
  VertSplit = { fg = c.border, bg = c.bg },
  WinSeparator = { link = "VertSplit" },
  StatusLine = { fg = c.fg, bg = c.bg },
  StatusLineNC = { fg = c.disabled, bg = c.bg_alt },
  TabLine = { fg = c.disabled, bg = c.bg },
  TabLineFill = { link = "TabLine" },
  TabLineSel = { fg = c.fg, bg = c.bg_alt },
  Pmenu = { fg = c.fg, bg = c.bg_alt },
  PmenuSel = { fg = c.fg, bg = c.bg_active },
  PmenuSbar = { bg = c.border },
  PmenuThumb = { bg = c.border_variant },
  WildMenu = { fg = c.fg, bg = c.bg_active },
  FloatBorder = { fg = c.border_variant, bg = c.bg_alt },
  FloatTitle = { fg = c.accent, bg = c.bg_alt },
  WinBar = { fg = c.muted, bg = c.bg },
  WinBarNC = { fg = c.disabled, bg = c.bg },
  Title = { fg = c.accent, bold = true },
  Directory = { fg = c.accent },
  Question = { fg = c.green },
  MoreMsg = { fg = c.green },
  ModeMsg = { fg = c.fg },
  MsgArea = { fg = c.fg },
  MsgSeparator = { fg = c.disabled },
  ErrorMsg = { fg = c.red },
  WarningMsg = { fg = c.yellow },
  QuickFixLine = { fg = c.accent },
  Search = { bg = "#493D36" },
  IncSearch = { fg = c.fg, bg = "#493D36" },
  CurSearch = { fg = c.bg, bg = c.accent },
  MatchParen = { fg = c.accent, bold = true },
  SpellBad = { sp = c.red, undercurl = true },
  SpellCap = { sp = c.green, undercurl = true },
  SpellLocal = { sp = c.yellow, undercurl = true },
  SpellRare = { sp = c.pink, undercurl = true },
})

-- Syntax
set_hl({
  Comment = { fg = c.disabled, italic = true },
  Constant = { fg = c.yellow },
  String = { fg = c.green },
  Character = { fg = c.green },
  Number = { fg = c.yellow },
  Boolean = { fg = c.salmon },
  Float = { link = "Number" },
  Identifier = { fg = c.fg },
  Function = { fg = c.accent },
  Method = { link = "Function" },
  Property = { fg = c.purple_light },
  Field = { link = "Property" },
  Parameter = { fg = c.param },
  Statement = { fg = c.pink },
  Conditional = { link = "Statement" },
  Repeat = { link = "Statement" },
  Label = { fg = c.purple },
  Operator = { fg = c.muted },
  Keyword = { fg = c.pink },
  Exception = { fg = c.magenta },
  PreProc = { fg = c.pink },
  Include = { link = "PreProc" },
  Define = { link = "PreProc" },
  Macro = { link = "PreProc" },
  PreCondit = { link = "PreProc" },
  Type = { fg = c.purple },
  StorageClass = { link = "Type" },
  Structure = { link = "Type" },
  Typedef = { link = "Type" },
  Special = { fg = c.magenta },
  SpecialChar = { link = "Special" },
  Tag = { fg = c.pink },
  Delimiter = { fg = c.muted },
  SpecialComment = { link = "Comment" },
  Debug = { fg = c.magenta },
  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Ignore = { fg = c.disabled },
  Error = { fg = c.red },
  Todo = { fg = c.accent, bold = true },
})

-- Treesitter
set_hl({
  ["@text"] = { fg = c.fg },
  ["@text.literal"] = { fg = c.green },
  ["@text.reference"] = { fg = c.purple_light },
  ["@text.title"] = { fg = c.accent, bold = true },
  ["@text.uri"] = { fg = c.purple_light, underline = true },
  ["@text.underline"] = { underline = true },
  ["@text.strong"] = { bold = true },
  ["@text.italic"] = { italic = true },
  ["@text.todo"] = { fg = c.accent, bold = true },
  ["@comment"] = { link = "Comment" },
  ["@punctuation"] = { link = "Delimiter" },
  ["@punctuation.bracket"] = { fg = c.muted },
  ["@punctuation.delimiter"] = { link = "Delimiter" },
  ["@punctuation.special"] = { fg = c.magenta },
  ["@constant"] = { link = "Constant" },
  ["@constant.builtin"] = { link = "Constant" },
  ["@constant.macro"] = { link = "Constant" },
  ["@string"] = { link = "String" },
  ["@string.escape"] = { fg = c.mint },
  ["@string.regex"] = { fg = c.mint },
  ["@string.special"] = { link = "Special" },
  ["@character"] = { link = "Character" },
  ["@number"] = { link = "Number" },
  ["@boolean"] = { link = "Boolean" },
  ["@float"] = { link = "Float" },
  ["@function"] = { link = "Function" },
  ["@function.builtin"] = { link = "Function" },
  ["@function.call"] = { link = "Function" },
  ["@function.macro"] = { link = "Function" },
  ["@method"] = { link = "Method" },
  ["@method.call"] = { link = "Method" },
  ["@constructor"] = { fg = c.purple },
  ["@parameter"] = { link = "Parameter" },
  ["@field"] = { link = "Field" },
  ["@property"] = { link = "Property" },
  ["@variable"] = { link = "Identifier" },
  ["@variable.builtin"] = { link = "Identifier" },
  ["@variable.parameter"] = { link = "Parameter" },
  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { link = "Type" },
  ["@type.definition"] = { link = "Type" },
  ["@type.qualifier"] = { link = "Type" },
  ["@keyword"] = { link = "Keyword" },
  ["@keyword.function"] = { link = "Keyword" },
  ["@keyword.operator"] = { link = "Operator" },
  ["@keyword.return"] = { link = "Keyword" },
  ["@label"] = { link = "Label" },
  ["@operator"] = { link = "Operator" },
  ["@exception"] = { link = "Exception" },
  ["@namespace"] = { link = "Type" },
  ["@attribute"] = { fg = c.yellow },
  ["@tag"] = { link = "Tag" },
  ["@tag.builtin"] = { link = "Tag" },
  ["@tag.delimiter"] = { link = "Delimiter" },
  ["@tag.attribute"] = { fg = c.yellow },
  ["@error"] = { link = "Error" },
  ["@warning"] = { link = "WarningMsg" },
  ["@info"] = { link = "DiagnosticInfo" },
  ["@hint"] = { link = "DiagnosticHint" },
  ["@none"] = { fg = c.fg },
})

-- LSP semantic tokens
set_hl({
  ["@lsp.type.namespace"] = { link = "@namespace" },
  ["@lsp.type.type"] = { link = "@type" },
  ["@lsp.type.class"] = { link = "@type" },
  ["@lsp.type.enum"] = { link = "@type" },
  ["@lsp.type.interface"] = { link = "@type" },
  ["@lsp.type.struct"] = { link = "@type" },
  ["@lsp.type.parameter"] = { link = "@parameter" },
  ["@lsp.type.variable"] = { link = "@variable" },
  ["@lsp.type.property"] = { link = "@property" },
  ["@lsp.type.enumMember"] = { link = "@constant" },
  ["@lsp.type.function"] = { link = "@function" },
  ["@lsp.type.method"] = { link = "@method" },
  ["@lsp.type.macro"] = { link = "@constant.macro" },
  ["@lsp.type.decorator"] = { link = "@function" },
  ["@lsp.type.builtinType"] = { link = "@type.builtin" },
  ["@lsp.type.comment"] = { link = "@comment" },
  ["@lsp.type.string"] = { link = "@string" },
  ["@lsp.type.keyword"] = { link = "@keyword" },
  ["@lsp.type.number"] = { link = "@number" },
  ["@lsp.type.operator"] = { link = "@operator" },
  ["@lsp.type.modifier"] = { link = "@type.qualifier" },
  ["@lsp.type.regexp"] = { link = "@string.regex" },
  ["@lsp.type.event"] = { link = "@type" },
  ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
  ["@lsp.type.typeParameter"] = { link = "@type.definition" },
})

-- Diagnostics
set_hl({
  DiagnosticError = { fg = c.red },
  DiagnosticWarn = { fg = c.yellow },
  DiagnosticInfo = { fg = c.purple },
  DiagnosticHint = { fg = c.muted },
  DiagnosticOk = { fg = c.green },
  DiagnosticUnderlineError = { sp = c.red, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c.purple, undercurl = true },
  DiagnosticUnderlineHint = { sp = c.muted, undercurl = true },
  DiagnosticVirtualTextError = { link = "DiagnosticError" },
  DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
  DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
  DiagnosticVirtualTextHint = { link = "DiagnosticHint" },
  DiagnosticSignError = { link = "DiagnosticError" },
  DiagnosticSignWarn = { link = "DiagnosticWarn" },
  DiagnosticSignInfo = { link = "DiagnosticInfo" },
  DiagnosticSignHint = { link = "DiagnosticHint" },
  DiagnosticFloatingError = { link = "DiagnosticError" },
  DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
  DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
  DiagnosticFloatingHint = { link = "DiagnosticHint" },
})

-- Diff
set_hl({
  DiffAdd = { fg = c.green },
  DiffChange = { fg = c.yellow },
  DiffDelete = { fg = c.red },
  DiffText = { fg = c.accent },
  Added = { fg = c.green },
  Changed = { fg = c.yellow },
  Removed = { fg = c.red },
})
