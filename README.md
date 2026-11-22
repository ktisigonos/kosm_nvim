# kosm_nvim

Neovim for kosm: its highlight groups and the terminal colors, written as `lua/kosm/theme.lua`
into Neovim's site folder (`~/.local/share/nvim/site`), with kosm's plugin beside it. Neovim
loads the site folder by itself, and so does lazy.nvim, so the plugin needs no install and your
config needs no line for it, nor knows kosm is there: it applies the colors at startup
and again whenever kosm writes them, and `:colorscheme kosm` brings them back after trying
another scheme.

A kosmos may name a colorscheme instead (`app.colorscheme = "catppuccin-mocha"`, installed like
any plugin); the plugin then loads that one in place of kosm's own groups, and `background`,
`groups` and the terminal colors still apply.

Your own config can read the colors through the plugin: `require('kosm').color('blue')` is a
terminal color's hex code (`'br_blue'` for the bright one; the current colorscheme's when it sets
one, else kosm's), and `require('kosm').on(hex)` the terminal's black or white, whichever reads
better on `hex`.

kosm owns these files under `directory` (`~/.local/share/nvim/site` by default):

| File | What it is |
|---|---|
| `lua/kosm/theme.lua` | the colors: `background`, `colorscheme`, `highlights` (kosm's own groups), `groups` (the kosmos' groups) and `terminal` |
| `lua/kosm/init.lua` | the plugin |
| `plugin/kosm.lua` | starts the plugin when Neovim loads its plugins |
| `colors/kosm.lua` | `:colorscheme kosm` |

With `plugin = false` only `lua/kosm/theme.lua` is written, for a config loading it itself. The
files are written through the `lua` adapter of `kosm_lua`, which this package brings along
(`kosm_nvim.lua_adapter`). Empty groups and null values are not written, so Neovim's own
default applies.

Neovim has no alpha: a background below full alpha, as with a theme's `background_alpha`, is
written as `bg = "NONE"`, so the terminal's translucent background shows through. Selections,
diff lines and other backgrounds that must stay visible are opaque.

The app's fields are Neovim's group names in snake case: `editor.cursor_line_nr` is
`CursorLineNr`, `diagnostics.underline_error` is `DiagnosticUnderlineError`,
`treesitter.variable_member` is `@variable.member`. Each is a `Highlight`, with `fg`, `bg`, `sp`,
the attributes (`bold`, `italic`, `underline`, `undercurl`, ...) and `link`, so one value can be
assigned on its own: `app.syntax.comment.italic = true`.

A minimal config can skip `from`: `kosm_nvim.App{}` writes an empty table of colors
(`return {}`), so assign only what you want.

`groups` sets groups the app has no field for, such as a plugin's, by Neovim's name, after kosm's
own groups or the colorscheme:
`.{ .name = "TreesitterContextBottom", .highlight = .{ .underline = true, .sp = kosm.hex("023142") } }`.
Without a colorscheme, one of the app's own groups fails the apply naming it (set its field
instead); with one, any group may be named. A group listed twice always fails.

`extra` adds values the app doesn't cover to the colors' table after its own, nested by path,
each a `kosm.Value`: `.{ .path = "accent.soft", .value = .{ .color = kosm.hex("2d8699") } }` is
`accent.soft`. An extra whose path equals, contains or lies inside a set value's or another
extra's fails the apply naming both.

## Fields

Every group is empty and every color null by default; the column says what `from(theme)` sets.
"Readable text" is `contrast.on` of the color behind it.

| Field | Default |
|---|---|
| `directory` | `~/.local/share/nvim/site`: Neovim's site folder; another `NVIM_APPNAME` or `XDG_DATA_HOME` needs its own |
| `plugin` | `true`: also write the plugin |
| `colorscheme` | null: kosm's own groups |
| `format` | `.{}`: the Lua adapter's `true`/`false`, then `#rrggbb` and 6 float decimals |
| `background` | null: not written; `from`: `"dark"` or `"light"`, the theme's mode, for the config to set Neovim's `background` option |
| `groups` | `&.{}`: the kosmos' groups, by name |
| `extra` | `&.{}`: values the app doesn't cover, by path |
| `editor.normal` | the foreground on the background |
| `editor.normal_float`, `editor.pmenu`, `editor.status_line` | the foreground on `surface.raised` of the background |
| `editor.float_border` | `line.border` of the background, on the float's background |
| `editor.cursor_line` | a `state.hovered` background |
| `editor.cursor_line_nr`, `editor.match_paren`, `editor.title` | the accent, bold |
| `editor.line_nr`, `editor.fold_column` | `emphasis.muted` of the foreground, as comments |
| `editor.non_text`, `editor.conceal` | `emphasis.faint` of the foreground |
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
