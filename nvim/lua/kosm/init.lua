-- kosm's Neovim plugin, written by kosm_nvim on every apply: edit your kosmos, not this file.
-- Applies lua/kosm/theme.lua, the colors kosm writes, and again whenever kosm rewrites it:
-- kosm's own highlight groups, or the colorscheme the kosmos names, then the kosmos' groups.
local M = {}

local directory = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
local path = directory .. '/theme.lua'
local applied
local theme = {}

-- Terminal colors 0..15 by name
local terminal_names = { 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white' }
for i = 1, 8 do
  terminal_names[i + 8] = 'br_' .. terminal_names[i]
end
local terminal_index = {}
for i, name in ipairs(terminal_names) do
  terminal_index[name] = i - 1
end

-- Without theme.lua Neovim's default colorscheme is used, so names fall back to its colors
local defaults = {
  black = 'NvimDarkGrey2',
  red = 'NvimLightRed',
  green = 'NvimLightGreen',
  yellow = 'NvimLightYellow',
  blue = 'NvimLightBlue',
  magenta = 'NvimLightMagenta',
  cyan = 'NvimLightCyan',
  white = 'NvimLightGrey2',
}
for name, color in pairs(vim.deepcopy(defaults)) do
  defaults['br_' .. name] = color
end
defaults.br_black, defaults.br_white = 'NvimDarkGrey4', 'NvimLightGrey1'

--- Hex code of a terminal color by name ('blue', 'br_blue'), or `name` itself when it is a hex
--- code: the current colorscheme's terminal color, else kosm's, else Neovim's default.
function M.color(name)
  if name:sub(1, 1) == '#' then return name end
  local index = terminal_index[name]
  if not index then error(("kosm: '%s' is neither a terminal color name ('blue', 'br_blue') nor a hex code"):format(name), 2) end
  local current = vim.g['terminal_color_' .. index]
  if type(current) == 'string' and current:sub(1, 1) == '#' then return current end
  if theme.terminal and theme.terminal[name] then return theme.terminal[name] end
  return ('#%06x'):format(vim.api.nvim_get_color_by_name(defaults[name]))
end

-- WCAG 2 relative luminance of a hex code, 0..1
local function luminance(hex)
  local total = 0
  for i, weight in ipairs { 0.2126, 0.7152, 0.0722 } do
    local channel = tonumber(hex:sub(2 * i, 2 * i + 1), 16) / 255
    total = total + weight * (channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4)
  end
  return total
end

local function contrast_ratio(a, b)
  local la, lb = luminance(a), luminance(b)
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05)
end

--- Readable text on `background` (a hex code): the terminal's black or white, whichever has the
--- higher WCAG contrast ratio, the same pick as kosm's `contrast.on`.
function M.on(background)
  local dark, light = M.color 'black', M.color 'white'
  return contrast_ratio(dark, background) >= contrast_ratio(light, background) and dark or light
end

-- Plugins' fallback groups (set with `default`). Some plugins define them only once at load, so
-- they are saved before any colorscheme clears highlights and put back where it set none.
local plugin_defaults = {}
local function save_plugin_defaults()
  for name, highlight in pairs(vim.api.nvim_get_hl(0, {})) do
    if highlight.default then plugin_defaults[name] = highlight end
  end
end

local function restore_plugin_defaults()
  for name, highlight in pairs(plugin_defaults) do
    if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = name })) then vim.api.nvim_set_hl(0, name, highlight) end
  end
end

local function set_highlights(groups)
  for name, highlight in pairs(groups or {}) do
    vim.api.nvim_set_hl(0, name, highlight)
  end
end

local function load_colorscheme(name)
  -- Left over from kosm's own colors, these would hide a scheme that sets none
  for i = 0, 15 do
    vim.g['terminal_color_' .. i] = nil
  end
  local ok, message = pcall(vim.cmd.colorscheme, name)
  if not ok then vim.notify(('kosm: cannot load the colorscheme %q that %s names: %s'):format(name, path, message), vim.log.levels.ERROR) end
end

local function load_own_colors()
  vim.cmd.highlight 'clear'
  set_highlights(theme.highlights)
  for i, name in ipairs(terminal_names) do
    vim.g['terminal_color_' .. (i - 1)] = (theme.terminal or {})[name]
  end
end

local function finish()
  restore_plugin_defaults()
  set_highlights(theme.groups)
  if not theme.colorscheme then
    -- A real name lets pickers restore these colors after previewing others
    vim.g.colors_name = 'kosm'
    vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'kosm' })
  end
end

--- Applies theme.lua. Skipped when it has not changed since the last apply, unless `force`.
--- `inside_colorscheme` is for colors/kosm.lua: Neovim cannot load a colorscheme while running
--- another one's file, so a named one then loads right after `:colorscheme kosm` returns.
function M.apply(force, inside_colorscheme)
  local file = io.open(path)
  if not file then
    if not applied or force then
      theme = {}
      vim.cmd.colorscheme 'default'
    end
    return
  end
  local source = file:read '*a'
  file:close()
  if source == applied and not force then return end

  local chunk, message = load(source, '@' .. path)
  local ok, loaded = false, message
  if chunk then
    ok, loaded = pcall(chunk)
  end
  if not ok or type(loaded) ~= 'table' then
    vim.notify(('kosm: cannot read %s: %s'):format(path, tostring(loaded)), vim.log.levels.ERROR)
    return
  end
  applied, theme = source, loaded

  -- Plugins pick dark or light colors from 'background'. Setting it reloads the current
  -- colorscheme, so the name is cleared first to keep it from re-entering this function.
  if theme.background and vim.o.background ~= theme.background then
    vim.g.colors_name = nil
    vim.o.background = theme.background
  end

  save_plugin_defaults()
  if not theme.colorscheme then
    load_own_colors()
    finish()
  elseif inside_colorscheme then
    vim.schedule(function()
      load_colorscheme(theme.colorscheme)
      finish()
    end)
  else
    load_colorscheme(theme.colorscheme)
    finish()
  end
end

local started = false

--- Applies theme.lua and watches it for kosm's next apply. Runs once; later calls do nothing.
function M.setup()
  if started then return end
  started = true
  M.apply()
  vim.api.nvim_create_autocmd('ColorSchemePre', {
    group = vim.api.nvim_create_augroup('kosm', { clear = true }),
    callback = save_plugin_defaults,
  })

  local watcher, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
  if not (watcher and timer) then return end
  -- The folder is watched, not the file, because kosm replaces the file (a new inode)
  watcher:start(directory, {}, function(err, name)
    if err or name ~= 'theme.lua' then return end
    timer:start(100, 0, vim.schedule_wrap(M.apply))
  end)
end

return M
