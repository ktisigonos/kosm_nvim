//! Neovim's standard syntax groups (`:h group-name`). Treesitter captures and LSP semantic
//! tokens link to them by default (`@keyword` to `Keyword`, `@lsp.type.function` to
//! `@function`), so these color every highlighted language. Each is empty by default, so not
//! written; the comments say what `from` sets. Groups linking to one of these by default
//! (`Conditional` to `Statement`, `Float` to `Number`) follow it.

const Syntax = @This();

const kosm = @import("kosm");
const Highlight = @import("Highlight.zig");
const names = @import("names.zig");

/// `Comment`: comments. `from`: `code.comment`.
comment: Highlight = .{},
/// `Constant`: constants, and through links booleans and characters. `from`: `code.constant`.
constant: Highlight = .{},
/// `String`: strings. `from`: `code.string`.
string: Highlight = .{},
/// `Character`: character literals. `from`: `code.string`.
character: Highlight = .{},
/// `Number`: numbers, and through a link floats. `from`: `code.number`.
number: Highlight = .{},
/// `Identifier`: variable names, and through links properties and parameters. `from`:
/// `code.variable`.
identifier: Highlight = .{},
/// `Function`: function and method names. `from`: `code.function`.
function: Highlight = .{},
/// `Statement`: statements, and through links conditionals, loops, labels and exceptions.
/// `from`: `code.keyword`.
statement: Highlight = .{},
/// `Keyword`: other keywords. `from`: `code.keyword`.
keyword: Highlight = .{},
/// `Operator`: operators. `from`: `code.operator`.
operator: Highlight = .{},
/// `PreProc`: preprocessor directives, and through links includes, macros and attributes.
/// `from`: `code.keyword`.
pre_proc: Highlight = .{},
/// `Type`: types, and through links modules, structures and storage classes. `from`: `code.type`.
type: Highlight = .{},
/// `Special`: builtins (`self`, builtin functions and constants), constructors and escapes.
/// `from`: `code.constant`.
special: Highlight = .{},
/// `Delimiter`: brackets, commas and other punctuation. `from`: `code.punctuation`.
delimiter: Highlight = .{},
/// `Tag`: markup tags. `from`: `code.tag`.
tag: Highlight = .{},
/// `Underlined`: links and other underlined text. `from`: the link role, underlined.
underlined: Highlight = .{},
/// `Todo`: `TODO`, `FIXME` and the like. `from`: the info role, bold.
todo: Highlight = .{},
/// `Error`: erroneous code. `from`: the error role.
@"error": Highlight = .{},

/// Neovim's name for the group in `field`.
pub fn groupName(comptime field: []const u8) []const u8 {
    return names.pascal("", field);
}

/// Groups from the theme's code colors and roles.
pub fn from(theme: kosm.Theme) Syntax {
    const code = theme.code;
    return .{
        .comment = .{ .fg = code.comment },
        .constant = .{ .fg = code.constant },
        .string = .{ .fg = code.string },
        .character = .{ .fg = code.string },
        .number = .{ .fg = code.number },
        .identifier = .{ .fg = code.variable },
        .function = .{ .fg = code.function },
        .statement = .{ .fg = code.keyword },
        .keyword = .{ .fg = code.keyword },
        .operator = .{ .fg = code.operator },
        .pre_proc = .{ .fg = code.keyword },
        .type = .{ .fg = code.type },
        .special = .{ .fg = code.constant },
        .delimiter = .{ .fg = code.punctuation },
        .tag = .{ .fg = code.tag },
        .underlined = .{ .fg = theme.roles.link, .underline = true },
        .todo = .{ .fg = theme.roles.info, .bold = true },
        .@"error" = .{ .fg = theme.roles.@"error" },
    };
}
