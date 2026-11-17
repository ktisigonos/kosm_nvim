//! One highlight group as `nvim_set_hl` takes it. Null values are not written; a group with
//! nothing set is not written at all, so Neovim's default for it applies.

const Highlight = @This();

const std = @import("std");
const kosm = @import("kosm");

/// Text color. Neovim has no alpha, so only the color is written.
fg: ?kosm.Color = null,
/// Background color. One with an alpha below 1 is written as `NONE`, so the terminal's
/// translucent background shows through instead.
bg: ?kosm.Color = null,
/// Color of underlines, undercurls and strikethroughs.
sp: ?kosm.Color = null,
/// Bold text.
bold: ?bool = null,
/// Italic text.
italic: ?bool = null,
/// A straight underline in `sp`.
underline: ?bool = null,
/// A curly underline in `sp`.
undercurl: ?bool = null,
/// A double underline in `sp`.
underdouble: ?bool = null,
/// A dotted underline in `sp`.
underdotted: ?bool = null,
/// A dashed underline in `sp`.
underdashed: ?bool = null,
/// A line through the text in `sp`.
strikethrough: ?bool = null,
/// Swaps `fg` and `bg`.
reverse: ?bool = null,
/// The terminal's standout mode.
standout: ?bool = null,
/// Keeps this group's attributes from combining with those of a group drawn below it.
nocombine: ?bool = null,
/// Another group's name, whose colors this group takes; Neovim then ignores the other values.
link: ?[]const u8 = null,

/// The group as a Lua table in field order, or null when nothing is set.
pub fn value(highlight: Highlight, allocator: std.mem.Allocator) std.mem.Allocator.Error!?kosm.Value {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (@typeInfo(Highlight).@"struct".field_names) |name| {
        if (@field(highlight, name)) |set| {
            const written: kosm.Value = switch (@TypeOf(set)) {
                kosm.Color => if (comptime std.mem.eql(u8, name, "bg")) background(set) else .{ .color = set },
                bool => .{ .boolean = set },
                []const u8 => .{ .string = set },
                else => @compileError("Highlight field '" ++ name ++ "' has no Lua spelling"),
            };
            try entries.append(allocator, .{ .key = name, .value = written });
        }
    }
    if (entries.items.len == 0) return null;
    return .{ .table = try entries.toOwnedSlice(allocator) };
}

fn background(color: kosm.Color) kosm.Value {
    return if (color.alpha < 1) .{ .string = "NONE" } else .{ .color = color };
}

const testing = std.testing;

test "only set values are written, in field order" {
    const highlight: Highlight = .{ .bold = true, .fg = kosm.hex("2d8699"), .link = "Title" };
    const written = (try highlight.value(testing.allocator)).?;
    defer testing.allocator.free(written.table);
    try testing.expectEqual(3, written.table.len);
    try testing.expectEqualStrings("fg", written.table[0].key);
    try testing.expectEqualStrings("bold", written.table[1].key);
    try testing.expectEqualStrings("Title", written.table[2].value.string);
}

test "a translucent background is written as NONE, an opaque one as its color" {
    var color = kosm.hex("041c26");
    const opaque_group = (try (Highlight{ .bg = color }).value(testing.allocator)).?;
    defer testing.allocator.free(opaque_group.table);
    try testing.expectEqual(color, opaque_group.table[0].value.color);
    color.alpha = 0.6;
    const translucent = (try (Highlight{ .bg = color, .fg = color }).value(testing.allocator)).?;
    defer testing.allocator.free(translucent.table);
    try testing.expectEqual(color, translucent.table[0].value.color);
    try testing.expectEqualStrings("NONE", translucent.table[1].value.string);
}

test "an empty highlight is not written" {
    try testing.expectEqual(null, try (Highlight{}).value(testing.allocator));
}
