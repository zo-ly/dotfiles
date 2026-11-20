-- WezTerm on Windows, with the shell running in WSL2. The Mac uses kitty (see kitty.conf).
-- This file lives in WSL (~/.config/wezterm/wezterm.lua, synced by Mackup); Windows reads it
-- through WEZTERM_CONFIG_FILE pointing at the \\wsl.localhost\ path. See AGENTS.md#wezterm-windows.
--
-- Key scheme: anything with CTRL+SHIFT belongs to the terminal; plain CTRL+letter and ALT+letter
-- go untouched to zsh / nvim. WezTerm's defaults already follow that, so only the gaps are filled
-- here. Common actions avoid arrow keys; the default arrow bindings are left in place.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Open straight into WSL. The name must match `wsl -l -v` on that machine.
config.default_domain = 'WSL:Ubuntu'

-- Appearance: the same Tokyo Night theme kitty uses. No font_family: the bundled JetBrains Mono
-- plus WezTerm's built-in Nerd Font symbols cover starship's icons.
config.color_scheme = 'Tokyo Night'
config.font_size = 12
config.window_background_opacity = 0.95
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 } -- kitty: inactive_text_alpha 0.5
config.check_for_updates = false -- nightly; update by reinstalling

config.keys = {
  -- Split, keeping the current directory (zsh reports it via OSC 7, see .zshrc)
  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Move between panes; replaces the defaults on K (ClearScrollback) and L (ShowDebugOverlay)
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },

  -- Swap the current pane with one picked by label
  { key = 's', mods = 'CTRL|SHIFT', action = act.PaneSelect { mode = 'SwapWithActive' } },

  -- Close the current pane (CTRL+SHIFT+W, the default, closes the whole tab)
  { key = 'd', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },
}

-- Links open on CTRL+click only; a plain click just selects, as in kitty (cmd+click there)
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
  -- Swallow the matching Down event so the program under the cursor does not see half a click
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.Nop,
  },
}

return config
