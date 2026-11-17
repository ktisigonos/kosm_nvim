//! Diagnostic groups (`:h diagnostic-highlights`), named without their `Diagnostic` prefix.
//! Virtual text, signs and floats link to the plain ones by default. Each is empty by default,
//! so not written; the comments say what `from` sets.

const Diagnostics = @This();

const kosm = @import("kosm");
const Highlight = @import("Highlight.zig");
const names = @import("names.zig");

/// `DiagnosticError`. `from`: the error role.
@"error": Highlight = .{},
/// `DiagnosticWarn`. `from`: the warning role.
warn: Highlight = .{},
/// `DiagnosticInfo`. `from`: the info role.
info: Highlight = .{},
/// `DiagnosticHint`. `from`: the secondary role.
hint: Highlight = .{},
/// `DiagnosticOk`. `from`: the success role.
ok: Highlight = .{},
/// `DiagnosticUnderlineError`: code with an error. `from`: an undercurl in the error role.
underline_error: Highlight = .{},
/// `DiagnosticUnderlineWarn`. `from`: an undercurl in the warning role.
underline_warn: Highlight = .{},
/// `DiagnosticUnderlineInfo`. `from`: an undercurl in the info role.
underline_info: Highlight = .{},
/// `DiagnosticUnderlineHint`. `from`: an undercurl in the secondary role.
underline_hint: Highlight = .{},
/// `DiagnosticUnderlineOk`. `from`: an undercurl in the success role.
underline_ok: Highlight = .{},

/// Neovim's name for the group in `field`.
pub fn groupName(comptime field: []const u8) []const u8 {
    return names.pascal("Diagnostic", field);
}

/// Groups from the theme's roles.
pub fn from(theme: kosm.Theme) Diagnostics {
    const roles = theme.roles;
    return .{
        .@"error" = .{ .fg = roles.@"error" },
        .warn = .{ .fg = roles.warning },
        .info = .{ .fg = roles.info },
        .hint = .{ .fg = roles.secondary },
        .ok = .{ .fg = roles.success },
        .underline_error = .{ .sp = roles.@"error", .undercurl = true },
        .underline_warn = .{ .sp = roles.warning, .undercurl = true },
        .underline_info = .{ .sp = roles.info, .undercurl = true },
        .underline_hint = .{ .sp = roles.secondary, .undercurl = true },
        .underline_ok = .{ .sp = roles.success, .undercurl = true },
    };
}
