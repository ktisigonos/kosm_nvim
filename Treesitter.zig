//! Treesitter captures (`:h treesitter-highlight-groups`) whose default link would not follow
//! the theme. Every other capture links to a `syntax` group or falls back to its parent
//! (`@variable.parameter` to `@variable`). Each is empty by default, so not written; the
//! comments say what `from` sets.

const Treesitter = @This();

const kosm = @import("kosm");
const Highlight = @import("Highlight.zig");
const names = @import("names.zig");

/// `@variable`: variables and parameters, which Neovim colors on its own rather than through
/// `Identifier`. `from`: `code.variable`.
variable: Highlight = .{},
/// `@variable.member`: fields of objects and structs. `from`: `code.property`.
variable_member: Highlight = .{},
/// `@property`: properties and keys. `from`: `code.property`.
property: Highlight = .{},
/// `@constructor`: constructor calls, and in Lua the braces of a table, which link to
/// `Special` by default. `from`: `code.type`.
constructor: Highlight = .{},
/// `@type.builtin`: builtin types (`u8`, `int`), which link to `Special` by default.
/// `from`: `code.type`.
type_builtin: Highlight = .{},
/// `@markup.raw`: code spans and blocks in Markdown and other markup. `from`: `code.string`.
markup_raw: Highlight = .{},
/// `@markup.link.url`: URLs in markup. `from`: the link role, underlined.
markup_link_url: Highlight = .{},

/// Neovim's name for the capture in `field`.
pub fn groupName(comptime field: []const u8) []const u8 {
    return names.capture(field);
}

/// Captures from the theme's code colors and roles.
pub fn from(theme: kosm.Theme) Treesitter {
    const code = theme.code;
    return .{
        .variable = .{ .fg = code.variable },
        .variable_member = .{ .fg = code.property },
        .property = .{ .fg = code.property },
        .constructor = .{ .fg = code.type },
        .type_builtin = .{ .fg = code.type },
        .markup_raw = .{ .fg = code.string },
        .markup_link_url = .{ .fg = theme.roles.link, .underline = true },
    };
}
