//! Neovim: its highlight groups and terminal colors generated as `lua/theme.lua`, for the nvim config to set.

const std = @import("std");

/// The colors; build them with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// The adapter the app writes with, so a config needs only this package to rice Neovim.
pub const lua_adapter = @import("kosm_lua").adapter;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
    std.testing.refAllDecls(@import("names.zig"));
}
