//! A highlight group the app has no field for, such as a plugin's, by Neovim's name.

const Highlight = @import("Highlight.zig");

/// Neovim's name for the group, e.g. `TreesitterContextBottom` or `@lsp.type.macro`.
name: []const u8,
/// Its colors and attributes.
highlight: Highlight,
