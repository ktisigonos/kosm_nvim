//! Neovim's group names from the app's snake_case field names.

const std = @import("std");

/// `prefix` and each word of `field` capitalized: `status_line_nc` is `StatusLineNC`, and with
/// the prefix `Diagnostic`, `underline_error` is `DiagnosticUnderlineError`. The word `nc`
/// (not current) is written `NC`, as in Neovim's names.
pub fn pascal(comptime prefix: []const u8, comptime field: []const u8) []const u8 {
    const result = comptime result: {
        var name: []const u8 = prefix;
        var words = std.mem.splitScalar(u8, field, '_');
        while (words.next()) |word| {
            name = name ++ if (std.mem.eql(u8, word, "nc")) "NC" else [_]u8{std.ascii.toUpper(word[0])} ++ word[1..];
        }
        break :result name[0..name.len].*;
    };
    return &result;
}

/// The Treesitter capture `field` names: `variable_member` is `@variable.member`. Neovim's
/// standard captures hold no `_`, so every one in `field` stands for a dot.
pub fn capture(comptime field: []const u8) []const u8 {
    const result = comptime result: {
        var dotted: [field.len]u8 = field[0..field.len].*;
        std.mem.replaceScalar(u8, &dotted, '_', '.');
        break :result ("@" ++ dotted).*;
    };
    return &result;
}

const testing = std.testing;

test "fields become Neovim's PascalCase names, nc as NC" {
    try testing.expectEqualStrings("Normal", pascal("", "normal"));
    try testing.expectEqualStrings("CursorLineNr", pascal("", "cursor_line_nr"));
    try testing.expectEqualStrings("StatusLineNC", pascal("", "status_line_nc"));
    try testing.expectEqualStrings("PmenuSbar", pascal("", "pmenu_sbar"));
    try testing.expectEqualStrings("DiagnosticUnderlineError", pascal("Diagnostic", "underline_error"));
    try testing.expectEqualStrings("DiagnosticError", pascal("Diagnostic", "error"));
}

test "fields become dotted captures" {
    try testing.expectEqualStrings("@variable", capture("variable"));
    try testing.expectEqualStrings("@variable.member", capture("variable_member"));
    try testing.expectEqualStrings("@markup.link.url", capture("markup_link_url"));
}
