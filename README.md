# kosm_nvim

Neovim for kosm: a base16 palette written to `~/.config/nvim/lua/theme.lua`, which returns it as
a Lua table. Load it from your own nvim config, for example with a base16 colorscheme
plugin:

```lua
local theme = require('theme')
```

The file is a Lua module returning one flat table (`theme.base00`, `theme.br_white`), written
through the `lua` adapter of `kosm_lua`, which this package brings along (`kosm_nvim.lua_adapter`).
Null values are not written.

A minimal config can skip `from`: `kosm_nvim.App{}` writes an empty module
(`return {}`), so assign only what you want (`.{ .base16 = .{ .base0D = kosm.hex("2d8699") } }`).

`extra` adds values the app doesn't cover to the module after its own, nested by path, each
a `kosm.Value`: `.{ .path = "accent.soft", .value = .{ .color = kosm.hex("2d8699") } }` is
`theme.accent.soft`. An extra whose path equals, contains or lies inside a set value's or another
extra's fails the apply naming both.

## Fields

Every color is null by default; the column says what `from(theme)` sets.

| Field | Default |
|---|---|
| `file` | `~/.config/nvim/lua/theme.lua` |
| `format` | `.{}`: the Lua adapter's `true`/`false`, then `#rrggbb` and 6 float decimals |
| `transparent` | null: `true` when the background (`base16.base00`) has an alpha below 1, as with a theme's `background_alpha`; else not written |
| `background` | null: not written; `from`: `"dark"` or `"light"`, the theme's mode, for the config to set Neovim's `background` option |
| `extra` | `&.{}`: values the app doesn't cover, by path |
| `base16.base00` | the theme's background role |
| `base16.base01` | `surface.raised` of `base00` |
| `base16.base02` | `state.selected` of `base00` |
| `base16.base03` | the theme's `code.comment` (comments) |
| `base16.base04` | `emphasis.muted` of `base05` |
| `base16.base05` | the theme's foreground role |
| `base16.base06` | `emphasis.strong` of `base05` |
| `base16.base07` | `lightness.bright` of `base05` |
| `base16.base08` | `code.tag` |
| `base16.base09` | `code.number` |
| `base16.base0A` | `code.type` |
| `base16.base0B` | `code.string` |
| `base16.base0C` | cyan |
| `base16.base0D` | `code.function` |
| `base16.base0E` | `code.keyword` |
| `base16.base0F` | pink |
| `terminal.black` ... `terminal.white` | the palette's black, white and the wheel's hues |
| `terminal.br_black` ... `terminal.br_white` | `lightness.bright` of each |
