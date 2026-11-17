//! Neovim's colors: its highlight groups and the terminal colors, generated into `file` as a
//! Lua module returning one table (`background`, `highlights`, `terminal`), for the user's own
//! nvim config to load with `require` and set with `nvim_set_hl`. Empty groups and null values
//! are not written.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The file kosm owns. Default: `~/.config/nvim/lua/theme.lua`.
file: []const u8 = "~/.config/nvim/lua/theme.lua",
/// How values are spelled, e.g. `.color = .hex_upper`. Null fields take the Lua
/// adapter's `true`/`false`, then kosm's `#rrggbb` and 6 float decimals.
format: kosm.Format = .{},
/// Neovim's `background` option, which plugins read to pick dark or light colors; the user's
/// config sets it from the module. null: not written. `from`: the theme's mode.
background: ?Background = null,
/// The groups of Neovim's own interface (`Normal`, `CursorLine`, `Pmenu`).
editor: Editor = .{},
/// The standard syntax groups (`Comment`, `Keyword`), which Treesitter captures link to.
syntax: Syntax = .{},
/// Treesitter captures whose default link would not follow the theme (`@variable`).
treesitter: Treesitter = .{},
/// Diagnostic groups (`DiagnosticError`, `DiagnosticUnderlineWarn`).
diagnostics: Diagnostics = .{},
/// Diff and version control groups (`DiffAdd`, `Added`).
diff: Diff = .{},
/// Groups the app has no field for, such as plugins', by Neovim's name, written after the
/// app's own. One the app already writes, or listed twice, fails the apply. Default: none.
groups: []const Group = &.{},
/// The 8 terminal colors and their bright variants, as `terminal.blue`, `terminal.br_blue`.
terminal: Terminal = .{},
/// Values the app doesn't cover, written into the module after its own, nested by path:
/// `.{ .path = "accent.soft", .value = .{ .color = kosm.hex("2d8699") } }` is `theme.accent.soft`.
/// One whose path equals, contains or lies inside a set value's or another extra's fails the
/// apply. Default: none.
extra: []const kosm.Setting = &.{},

/// Neovim's `background`: whether the colors are dark or light.
pub const Background = enum { dark, light };

pub const Highlight = @import("Highlight.zig");
pub const Group = @import("Group.zig");
pub const Editor = @import("Editor.zig");
pub const Syntax = @import("Syntax.zig");
pub const Treesitter = @import("Treesitter.zig");
pub const Diagnostics = @import("Diagnostics.zig");
pub const Diff = @import("Diff.zig");
pub const Terminal = @import("Terminal.zig");

/// Colors from the theme: the interface from the roles and variations, syntax and Treesitter
/// from the code colors, diagnostics from the roles, diffs from the diff colors, and the
/// terminal colors from the palette.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    const bright = theme.variations.lightness.bright;
    return .{
        .background = switch (theme.mode) {
            .dark => .dark,
            .light => .light,
        },
        .editor = .from(theme),
        .syntax = .from(theme),
        .treesitter = .from(theme),
        .diagnostics = .from(theme),
        .diff = .from(theme),
        .terminal = .{
            .black = palette.black,
            .red = palette.red,
            .green = palette.green,
            .yellow = palette.yellow,
            .blue = palette.blue,
            .magenta = palette.magenta,
            .cyan = palette.cyan,
            .white = palette.white,
            .br_black = bright.apply(palette.black),
            .br_red = bright.apply(palette.red),
            .br_green = bright.apply(palette.green),
            .br_yellow = bright.apply(palette.yellow),
            .br_blue = bright.apply(palette.blue),
            .br_magenta = bright.apply(palette.magenta),
            .br_cyan = bright.apply(palette.cyan),
            .br_white = bright.apply(palette.white),
        },
    };
}

/// Writes every set value to `file`, then the extras.
pub fn apply(self: App, output: *kosm.Output) !void {
    const values = try kosm.Setting.leaves(output.allocator, try self.tree(output));
    const all = try kosm.Setting.withExtras(output, self.file, values, self.extra, .{});
    try output.generate(.{ .file = self.file, .lang = "lua", .format = self.format }, try kosm.Setting.tree(output.allocator, all));
}

/// `background`, then the groups under `highlights`, then the colors under `terminal`; an empty
/// table is left out.
fn tree(self: App, output: *kosm.Output) kosm.Output.Error!kosm.Value {
    const allocator = output.allocator;
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    if (self.background) |background| try entries.append(allocator, .{ .key = "background", .value = .{ .string = @tagName(background) } });
    const highlights = try self.highlightEntries(output);
    if (highlights.len != 0) try entries.append(allocator, .{ .key = "highlights", .value = .{ .table = highlights } });
    const terminal = try terminalEntries(allocator, self.terminal);
    if (terminal.len != 0) try entries.append(allocator, .{ .key = "terminal", .value = .{ .table = terminal } });
    return .{ .table = entries.items };
}

/// Every written group by Neovim's name: the app's own, then `groups`.
fn highlightEntries(self: App, output: *kosm.Output) kosm.Output.Error![]const kosm.Value.Entry {
    const allocator = output.allocator;
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    try appendGroups(allocator, &entries, self.editor);
    try appendGroups(allocator, &entries, self.syntax);
    try appendGroups(allocator, &entries, self.treesitter);
    try appendGroups(allocator, &entries, self.diagnostics);
    try appendGroups(allocator, &entries, self.diff);
    for (self.groups) |group| {
        for (entries.items) |entry| {
            if (std.mem.eql(u8, entry.key, group.name)) return output.fail(self.file, "group '{s}' in groups is already written, by one of the app's fields or an earlier entry; set it once", .{group.name});
        }
        if (try group.highlight.value(allocator)) |value| try entries.append(allocator, .{ .key = group.name, .value = value });
    }
    return entries.items;
}

fn appendGroups(allocator: std.mem.Allocator, entries: *std.ArrayList(kosm.Value.Entry), groups: anytype) std.mem.Allocator.Error!void {
    const Groups = @TypeOf(groups);
    inline for (@typeInfo(Groups).@"struct".field_names) |name| {
        if (try @field(groups, name).value(allocator)) |value| try entries.append(allocator, .{ .key = Groups.groupName(name), .value = value });
    }
}

fn terminalEntries(allocator: std.mem.Allocator, terminal: Terminal) std.mem.Allocator.Error![]const kosm.Value.Entry {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (@typeInfo(Terminal).@"struct".field_names) |name| {
        if (@field(terminal, name)) |color| try entries.append(allocator, .{ .key = name, .value = .{ .color = color } });
    }
    return entries.items;
}

const testing = std.testing;
const lua = @import("kosm_lua");

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{lua.adapter},
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "nvim",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn written(fixture: *Fixture) []const u8 {
        return fixture.plan.files.items[0].new;
    }
};

fn contains(haystack: []const u8, needle: []const u8) bool {
    return std.mem.indexOf(u8, haystack, needle) != null;
}

const test_palette: kosm.Palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc"), .red = kosm.hex("80333c"), .cyan = kosm.hex("2e9990") };

test "apply writes the background, the groups by Neovim's names and the terminal colors" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const theme = kosm.Theme.from(.{ .palette = test_palette, .mode = .dark });
    var app = from(theme);
    app.terminal.br_white = kosm.hex("b7dce5");
    try app.apply(&fixture.output);
    try testing.expectEqual(0, fixture.warnings.items.items.len);

    const written = fixture.written();
    try testing.expectStringStartsWith(written, "return {\n    background = \"dark\",\n    highlights = {\n        Normal = {\n            fg = \"#a3c5cc\",\n            bg = \"#041c26\",\n        },\n");
    try testing.expect(contains(written, "\n        CursorLineNr = {\n            fg = \"#2e9990\",\n            bold = true,\n        },\n"));
    try testing.expect(contains(written, "\n        StatusLineNC = {\n"));
    try testing.expect(contains(written, "\n        [\"@variable.member\"] = {\n"));
    try testing.expect(contains(written, "\n        DiagnosticUnderlineError = {\n            sp = \"#80333c\",\n            undercurl = true,\n        },\n"));
    try testing.expect(contains(written, "\n        DiffAdd = {\n"));
    try testing.expect(contains(written, "\n    terminal = {\n        black = \"#041c26\",\n"));
    try testing.expectStringEndsWith(written, "\n        br_white = \"#b7dce5\",\n    },\n}\n");
}

test "a light theme writes a light background" {
    const theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("d8ecf1") }, .mode = .light });
    try testing.expectEqual(.light, from(theme).background);
}

test "a translucent background writes NONE where the window shows, and opaque colors where it must not" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    var theme = kosm.Theme.from(.{ .palette = test_palette, .mode = .dark });
    theme.background_alpha = 0.5;
    const app = from(theme);
    try app.apply(&fixture.output);
    const written = fixture.written();
    try testing.expect(contains(written, "\n        Normal = {\n            fg = \"#a3c5cc\",\n            bg = \"NONE\",\n        },\n"));
    try testing.expect(contains(written, "\n        Pmenu = {\n            fg = \"#a3c5cc\",\n            bg = \"NONE\",\n        },\n"));
    try testing.expect(!contains(written, "\n        Visual = {\n            bg = \"NONE\""));
    try testing.expectEqual(1, app.editor.visual.bg.?.alpha);
    try testing.expectEqual(1, app.diff.diff_add.bg.?.alpha);
}

test "App{} writes an empty module, and only set groups and values are written" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const empty: App = .{};
    try empty.apply(&fixture.output);
    try testing.expectEqualStrings("return {}\n", fixture.written());

    var app: App = .{};
    app.editor.cursor_line.bg = kosm.hex("0d2630");
    app.terminal.cyan = kosm.hex("268078");
    const tree_value = try app.tree(&fixture.output);
    try testing.expectEqual(2, tree_value.table.len);
    try testing.expectEqualStrings("CursorLine", tree_value.table[0].value.table[0].key);
    try testing.expectEqual(1, tree_value.table[0].value.table.len);
    try testing.expectEqualStrings("cyan", tree_value.table[1].value.table[0].key);
}

test "groups are written by name after the app's own, and one already written fails naming it" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    var app: App = .{};
    app.syntax.comment.fg = kosm.hex("758387");
    app.groups = &.{
        .{ .name = "TreesitterContextBottom", .highlight = .{ .underline = true, .sp = kosm.hex("023142") } },
        .{ .name = "@lsp.type.macro", .highlight = .{ .link = "Macro" } },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\return {
        \\    highlights = {
        \\        Comment = {
        \\            fg = "#758387",
        \\        },
        \\        TreesitterContextBottom = {
        \\            sp = "#023142",
        \\            underline = true,
        \\        },
        \\        ["@lsp.type.macro"] = {
        \\            link = "Macro",
        \\        },
        \\    },
        \\}
        \\
    , fixture.written());

    app.groups = &.{.{ .name = "Comment", .highlight = .{ .italic = true } }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("group 'Comment' in groups is already written, by one of the app's fields or an earlier entry; set it once", fixture.diagnostics.message());
}

test "extras follow the app's values, nested by path, and a clash fails naming both" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    var app: App = .{};
    app.editor.normal.fg = kosm.hex("a3c5cc");
    app.extra = &.{
        .{ .path = "accent.soft", .value = .{ .color = kosm.hex("2d8699") } },
        .{ .path = "highlights.Normal.italic", .value = .{ .boolean = true } },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\return {
        \\    highlights = {
        \\        Normal = {
        \\            fg = "#a3c5cc",
        \\            italic = true,
        \\        },
        \\    },
        \\    accent = {
        \\        soft = "#2d8699",
        \\    },
        \\}
        \\
    , fixture.written());

    app.extra = &.{.{ .path = "highlights.Normal.fg.dim", .value = .{ .color = kosm.hex("000000") } }};
    try testing.expectError(error.AppFailed, app.apply(&fixture.output));
    try testing.expectEqualStrings("extra 'highlights.Normal.fg.dim' and setting 'highlights.Normal.fg' write the same key, or one inside the other; keep one", fixture.diagnostics.message());
}
