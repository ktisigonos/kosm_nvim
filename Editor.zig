//! The groups of Neovim's own interface (`:h highlight-groups`). Each is empty by default, so
//! not written; the comments say what `from` sets. A background below full alpha is written as
//! `NONE`, so with a theme's `background_alpha` the terminal's translucency shows through.

const Editor = @This();

const kosm = @import("kosm");
const Highlight = @import("Highlight.zig");
const names = @import("names.zig");

/// `Normal`: text and the window. `from`: the foreground on the background.
normal: Highlight = .{},
/// `NormalFloat`: floating windows. `from`: the foreground on `surface.raised` of the background.
normal_float: Highlight = .{},
/// `FloatBorder`: floating windows' borders. `from`: `line.border` on the float's background.
float_border: Highlight = .{},
/// `CursorLine`: the cursor's line. `from`: a `state.hovered` background.
cursor_line: Highlight = .{},
/// `CursorLineNr`: the cursor's line number. `from`: the accent, bold.
cursor_line_nr: Highlight = .{},
/// `LineNr`: line numbers, and with `relativenumber` the distances to the cursor's line.
/// `from`: `emphasis.muted` of the foreground, as comments, so they stay readable.
line_nr: Highlight = .{},
/// `FoldColumn`: the fold column. `from`: as `line_nr`.
fold_column: Highlight = .{},
/// `Folded`: closed folds. `from`: `emphasis.muted` text on a `surface.raised` background.
folded: Highlight = .{},
/// `NonText`: filler such as `~` past the end, `showbreak` and inlay hints. `from`:
/// `emphasis.faint` of the foreground.
non_text: Highlight = .{},
/// `Visual`: the visual selection. `from`: a `state.selected` background, always opaque.
visual: Highlight = .{},
/// `Search`: search matches. `from`: the secondary role behind readable text.
search: Highlight = .{},
/// `CurSearch`: the search match under the cursor. `from`: the accent behind readable text, bold.
cur_search: Highlight = .{},
/// `IncSearch`: the match while typing a search. `from`: as `cur_search`.
inc_search: Highlight = .{},
/// `MatchParen`: the bracket matching the one under the cursor. `from`: the accent, bold.
match_paren: Highlight = .{},
/// `Pmenu`: the completion menu. `from`: as `normal_float`.
pmenu: Highlight = .{},
/// `PmenuSel`: its selected item. `from`: the accent behind readable text, bold.
pmenu_sel: Highlight = .{},
/// `PmenuSbar`: its scrollbar's track. `from`: the menu's background.
pmenu_sbar: Highlight = .{},
/// `PmenuThumb`: its scrollbar's thumb. `from`: a `line.border` background, always opaque.
pmenu_thumb: Highlight = .{},
/// `StatusLine`: the current window's status line. `from`: the foreground on `surface.raised`.
status_line: Highlight = .{},
/// `StatusLineNC`: other windows' status lines. `from`: `emphasis.muted` text on `surface.raised`.
status_line_nc: Highlight = .{},
/// `WinSeparator`: lines between windows. `from`: `line.separator` of the background.
win_separator: Highlight = .{},
/// `TabLine`: tabs other than the current one. `from`: as `status_line_nc`.
tab_line: Highlight = .{},
/// `TabLineFill`: the tab line past the tabs. `from`: a `surface.raised` background.
tab_line_fill: Highlight = .{},
/// `TabLineSel`: the current tab. `from`: the accent behind readable text, bold.
tab_line_sel: Highlight = .{},
/// `WinBar`: the current window's bar. `from`: the foreground, bold.
win_bar: Highlight = .{},
/// `WinBarNC`: other windows' bars. `from`: `emphasis.muted` of the foreground.
win_bar_nc: Highlight = .{},
/// `Title`: titles and Markdown headings. `from`: the accent, bold.
title: Highlight = .{},
/// `Directory`: directory names. `from`: the secondary role.
directory: Highlight = .{},
/// `ErrorMsg`: error messages. `from`: the error role.
error_msg: Highlight = .{},
/// `WarningMsg`: warning messages. `from`: the warning role.
warning_msg: Highlight = .{},
/// `MoreMsg`: the "more" prompt. `from`: the info role.
more_msg: Highlight = .{},
/// `ModeMsg`: the mode shown in the command line. `from`: the foreground, bold.
mode_msg: Highlight = .{},
/// `Question`: prompts asking for a choice. `from`: the info role.
question: Highlight = .{},
/// `ColorColumn`: the `colorcolumn` columns. `from`: a `surface.raised` background, always opaque.
color_column: Highlight = .{},
/// `QuickFixLine`: the current quickfix item. `from`: as `visual`.
quick_fix_line: Highlight = .{},
/// `Conceal`: placeholders for concealed text. `from`: `emphasis.faint` of the foreground.
conceal: Highlight = .{},
/// `SpellBad`: misspelled words. `from`: an undercurl in the error role.
spell_bad: Highlight = .{},
/// `SpellCap`: words that should start with a capital. `from`: an undercurl in the warning role.
spell_cap: Highlight = .{},
/// `SpellLocal`: words of another region. `from`: an undercurl in the info role.
spell_local: Highlight = .{},
/// `SpellRare`: rarely used words. `from`: an undercurl in the tertiary role.
spell_rare: Highlight = .{},

/// Neovim's name for the group in `field`.
pub fn groupName(comptime field: []const u8) []const u8 {
    return names.pascal("", field);
}

/// Groups from the theme's roles and variations.
pub fn from(theme: kosm.Theme) Editor {
    const roles = theme.roles;
    const variations = theme.variations;
    const window = theme.asBackground(roles.background);
    const raised = variations.surface.raised.apply(window);
    const muted = variations.emphasis.muted.apply(roles.foreground);
    const faint = variations.emphasis.faint.apply(roles.foreground);
    const selected = variations.state.selected.apply(roles.background);
    const accented: Highlight = .{ .fg = variations.contrast.on.apply(roles.accent), .bg = roles.accent, .bold = true };
    const float: Highlight = .{ .fg = roles.foreground, .bg = raised };
    const behind_tabs: Highlight = .{ .fg = muted, .bg = raised };
    return .{
        .normal = .{ .fg = roles.foreground, .bg = window },
        .normal_float = float,
        .float_border = .{ .fg = variations.line.border.apply(roles.background), .bg = raised },
        .cursor_line = .{ .bg = variations.state.hovered.apply(window) },
        .cursor_line_nr = .{ .fg = roles.accent, .bold = true },
        .line_nr = .{ .fg = muted },
        .fold_column = .{ .fg = muted },
        .folded = .{ .fg = muted, .bg = raised },
        .non_text = .{ .fg = faint },
        .visual = .{ .bg = selected },
        .search = .{ .fg = variations.contrast.on.apply(roles.secondary), .bg = roles.secondary },
        .cur_search = accented,
        .inc_search = accented,
        .match_paren = .{ .fg = roles.accent, .bold = true },
        .pmenu = float,
        .pmenu_sel = accented,
        .pmenu_sbar = .{ .bg = raised },
        .pmenu_thumb = .{ .bg = variations.line.border.apply(roles.background) },
        .status_line = float,
        .status_line_nc = behind_tabs,
        .win_separator = .{ .fg = variations.line.separator.apply(roles.background) },
        .tab_line = behind_tabs,
        .tab_line_fill = .{ .bg = raised },
        .tab_line_sel = accented,
        .win_bar = .{ .fg = roles.foreground, .bold = true },
        .win_bar_nc = .{ .fg = muted },
        .title = .{ .fg = roles.accent, .bold = true },
        .directory = .{ .fg = roles.secondary },
        .error_msg = .{ .fg = roles.@"error" },
        .warning_msg = .{ .fg = roles.warning },
        .more_msg = .{ .fg = roles.info },
        .mode_msg = .{ .fg = roles.foreground, .bold = true },
        .question = .{ .fg = roles.info },
        .color_column = .{ .bg = variations.surface.raised.apply(roles.background) },
        .quick_fix_line = .{ .bg = selected },
        .conceal = .{ .fg = faint },
        .spell_bad = .{ .sp = roles.@"error", .undercurl = true },
        .spell_cap = .{ .sp = roles.warning, .undercurl = true },
        .spell_local = .{ .sp = roles.info, .undercurl = true },
        .spell_rare = .{ .sp = roles.tertiary, .undercurl = true },
    };
}
