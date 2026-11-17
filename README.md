# kosm_nvim

Neovim for kosm: its highlight groups and the terminal colors, written to
`~/.config/nvim/lua/theme.lua`, which returns them as one Lua table. No colorscheme plugin is
needed; set them from your own nvim config:

```lua
local theme = require('theme')
vim.cmd.highlight 'clear'
if theme.background then vim.o.background = theme.background end
for name, highlight in pairs(theme.highlights or {}) do
  vim.api.nvim_set_hl(0, name, highlight)
end
vim.g.colors_name = 'kosm'
```

The table holds `background` (`"dark"` or `"light"`), `highlights` (each group by Neovim's name,
as `nvim_set_hl` takes it: `highlights.CursorLine`, `highlights["@variable.member"]`) and
`terminal` (`terminal.blue`, `terminal.br_blue`). It is written through the `lua` adapter of
`kosm_lua`, which this package brings along (`kosm_nvim.lua_adapter`). Empty groups and null
values are not written, so Neovim's own default applies.

Neovim has no alpha: a background below full alpha, as with a theme's `background_alpha`, is
written as `bg = "NONE"`, so the terminal's translucent background shows through. Selections,
diff lines and other backgrounds that must stay visible are opaque.

The app's fields are Neovim's group names in snake case: `editor.cursor_line_nr` is
`CursorLineNr`, `diagnostics.underline_error` is `DiagnosticUnderlineError`,
`treesitter.variable_member` is `@variable.member`. Each is a `Highlight`, with `fg`, `bg`, `sp`,
the attributes (`bold`, `italic`, `underline`, `undercurl`, ...) and `link`, so one value can be
assigned on its own: `app.syntax.comment.italic = true`.

A minimal config can skip `from`: `kosm_nvim.App{}` writes an empty module
(`return {}`), so assign only what you want.

`groups` adds groups the app has no field for, such as a plugin's, by Neovim's name:
`.{ .name = "TreesitterContextBottom", .highlight = .{ .underline = true, .sp = kosm.hex("023142") } }`.
One the app already writes, or listed twice, fails the apply naming it.

`extra` adds values the app doesn't cover to the module after its own, nested by path, each
a `kosm.Value`: `.{ .path = "accent.soft", .value = .{ .color = kosm.hex("2d8699") } }` is
`theme.accent.soft`. An extra whose path equals, contains or lies inside a set value's or another
extra's fails the apply naming both.

## Fields

Every group is empty and every color null by default; the column says what `from(theme)` sets.
"Readable text" is `contrast.on` of the color behind it.

| Field | Default |
|---|---|
| `file` | `~/.config/nvim/lua/theme.lua` |
| `format` | `.{}`: the Lua adapter's `true`/`false`, then `#rrggbb` and 6 float decimals |
| `background` | null: not written; `from`: `"dark"` or `"light"`, the theme's mode, for the config to set Neovim's `background` option |
| `groups` | `&.{}`: groups the app has no field for, by name |
| `extra` | `&.{}`: values the app doesn't cover, by path |
| `editor.normal` | the foreground on the background |
| `editor.normal_float`, `editor.pmenu`, `editor.status_line` | the foreground on `surface.raised` of the background |
| `editor.float_border` | `line.border` of the background, on the float's background |
| `editor.cursor_line` | a `state.hovered` background |
| `editor.cursor_line_nr`, `editor.match_paren`, `editor.title` | the accent, bold |
| `editor.line_nr`, `editor.fold_column`, `editor.non_text`, `editor.conceal` | `emphasis.faint` of the foreground |
| `editor.folded` | `emphasis.muted` text on `surface.raised` |
| `editor.visual`, `editor.quick_fix_line` | a `state.selected` background, opaque |
| `editor.search` | the secondary role behind readable text |
| `editor.cur_search`, `editor.inc_search`, `editor.pmenu_sel`, `editor.tab_line_sel` | the accent behind readable text, bold |
| `editor.pmenu_sbar`, `editor.tab_line_fill` | a `surface.raised` background |
| `editor.pmenu_thumb` | a `line.border` background, opaque |
| `editor.status_line_nc`, `editor.tab_line` | `emphasis.muted` text on `surface.raised` |
| `editor.win_separator` | `line.separator` of the background |
| `editor.win_bar`, `editor.mode_msg` | the foreground, bold |
| `editor.win_bar_nc` | `emphasis.muted` of the foreground |
| `editor.directory` | the secondary role |
| `editor.error_msg`, `editor.warning_msg` | the error and warning roles |
| `editor.more_msg`, `editor.question` | the info role |
| `editor.color_column` | a `surface.raised` background, opaque |
| `editor.spell_bad`, `spell_cap`, `spell_local`, `spell_rare` | an undercurl in the error, warning, info and tertiary roles |
| `syntax.comment`, `string`, `number`, `constant`, `function`, `keyword`, `type`, `operator`, `tag` | the code color of the same name |
| `syntax.character` | `code.string` |
| `syntax.identifier` | `code.variable` |
| `syntax.statement`, `syntax.pre_proc` | `code.keyword` |
| `syntax.special` | `code.constant`: builtins, constructors and escapes |
| `syntax.delimiter` | `code.punctuation` |
| `syntax.underlined` | the link role, underlined |
| `syntax.todo` | the info role, bold |
| `syntax.error` | the error role |
| `treesitter.variable` | `code.variable` |
| `treesitter.variable_member`, `treesitter.property` | `code.property` |
| `treesitter.constructor`, `treesitter.type_builtin` | `code.type` |
| `treesitter.markup_raw` | `code.string` |
| `treesitter.markup_link_url` | the link role, underlined |
| `diagnostics.error`, `warn`, `info`, `hint`, `ok` | the error, warning, info, secondary and success roles |
| `diagnostics.underline_error` ... `underline_ok` | an undercurl in the same roles |
| `diff.diff_add`, `diff.diff_change` | the background tinted 20% toward the added and changed colors |
| `diff.diff_delete` | the removed color on the background tinted 20% toward it |
| `diff.diff_text` | the background tinted 40% toward the changed color |
| `diff.added`, `diff.changed`, `diff.removed` | the theme's diff colors |
| `terminal.black` ... `terminal.white` | the palette's black, white and the wheel's hues |
| `terminal.br_black` ... `terminal.br_white` | `lightness.bright` of each |

Other syntax groups and Treesitter captures follow these through Neovim's default links
(`Conditional` to `Statement`, `@keyword` to `Keyword`, `@lsp.type.function` to `@function`).
