//! Diff and version control groups. `Diff*` color the lines of `:diffthis` and diff views with
//! backgrounds; `Added`, `Changed` and `Removed` color text, and git signs, `@diff.plus` and
//! the like link to them. Each is empty by default, so not written; the comments say what
//! `from` sets.

const Diff = @This();

const kosm = @import("kosm");
const Highlight = @import("Highlight.zig");
const names = @import("names.zig");

/// How far the line backgrounds mix from the opaque background toward their diff color, 0..1.
const line_tint: f64 = 0.2;
/// How far `DiffText` mixes toward the changed color, stronger than a changed line.
const text_tint: f64 = 0.4;

/// `DiffAdd`: added lines. `from`: the background tinted toward the added color, opaque.
diff_add: Highlight = .{},
/// `DiffChange`: changed lines. `from`: the background tinted toward the changed color, opaque.
diff_change: Highlight = .{},
/// `DiffDelete`: filler where lines were removed. `from`: the removed color on the background
/// tinted toward it, opaque.
diff_delete: Highlight = .{},
/// `DiffText`: the changed text inside a changed line. `from`: the background tinted more
/// strongly toward the changed color, opaque.
diff_text: Highlight = .{},
/// `Added`: added text and signs. `from`: the added color.
added: Highlight = .{},
/// `Changed`: changed text and signs. `from`: the changed color.
changed: Highlight = .{},
/// `Removed`: removed text and signs. `from`: the removed color.
removed: Highlight = .{},

/// Neovim's name for the group in `field`.
pub fn groupName(comptime field: []const u8) []const u8 {
    return names.pascal("", field);
}

/// Groups from the theme's diff colors.
pub fn from(theme: kosm.Theme) Diff {
    const colors = theme.diff;
    const background = theme.roles.background;
    return .{
        .diff_add = .{ .bg = background.mix(colors.added, line_tint) },
        .diff_change = .{ .bg = background.mix(colors.changed, line_tint) },
        .diff_delete = .{ .fg = colors.removed, .bg = background.mix(colors.removed, line_tint) },
        .diff_text = .{ .bg = background.mix(colors.changed, text_tint) },
        .added = .{ .fg = colors.added },
        .changed = .{ .fg = colors.changed },
        .removed = .{ .fg = colors.removed },
    };
}
