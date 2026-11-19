# Config

`~/.config/jzero/config` (Windows: `%APPDATA%\jzero\config\config`; `~/.config/jzero` below means that folder, app state is `%APPDATA%\jzero`): flat `key = value`, `#` comments, hot reload. Source of truth: `src/config/config.j3`, `src/input/keymap.j3`, `src/actions.j3`.
Theme files (Ghostty, base16 YAML, iTerm2): `~/.config/jzero/themes/`. Island templates: `~/.config/jzero/templates/`. App state: `~/.local/share/jzero/`.

## Keys
| Key | Default | Notes |
| --- | --- | --- |
| font-size | 14 | |
| font-family | bundled | family (`fc-match`; Windows: a font file name in the Fonts folders, e.g. `consola`) or file path |
| font-ligatures | true | needs SDL_ttf with HarfBuzz |
| line-height | 100 | percent, 100–300 |
| padding | 10 | `x` or `x,y` px |
| theme | tango | bundled or from themes/ |
| palette / background / foreground / cursor-color / selection-background | theme | `palette = 3=#rrggbb` |
| scrollback | 10000 | lines |
| shell | $SHELL (Windows: pwsh → powershell → cmd) | |
| shell-integration | true | |
| keybind | | `ctrl+shift+o=split_right`, repeatable, `=none` unbinds |
| quick-terminal-key | none | global combo (X11), e.g. `ctrl+grave` |
| cursor-style | block | block / bar / underline |
| cursor-blink | true | |
| unfocused-split-opacity | 100 | percent |
| background-opacity | 100 | percent; below 100 must be set before start |
| clipboard-write | true | OSC 52 |
| desktop-notifications | true | OSC 9/777 + long-command notice |
| visual-bell | true | |
| confirm-close | true | ask while a program runs |
| notify-after | 10 | seconds, 0 off |
| explorer-hidden | false | show dotfiles |
| notes-dir | data dir notes/ | |

## Default keys
| Combo | Action |
| --- | --- |
| Ctrl+Shift+C / V | copy / paste |
| Ctrl+Shift+T | new island |
| Ctrl+, | settings |
| Ctrl+Shift+P | command palette |
| Ctrl+Shift+B | explorer |
| Del / Ctrl+C / Ctrl+X / Ctrl+V | explorer: trash / copy / cut / paste picked files (fixed, not rebindable) |
| Mouse Back | explorer: close the open file, else parent folder |
| Ctrl+Shift+O / E | split right / down |
| Ctrl+Shift+W | close pane |
| Ctrl+Shift+= | equalize splits |
| Ctrl+Alt+arrows | focus pane |
| Ctrl+Shift+PageUp / PageDown | previous / next prompt |
| Ctrl+= / - / 0 | font size |
| Ctrl+Tab / Ctrl+Shift+Tab | next / previous island |
| Ctrl+Shift+F | find |
| Ctrl+Shift+H | search everything |
| Ctrl+Shift+Y | copy last output |
| Ctrl+Shift+Enter | zoom pane |
| Ctrl+Shift+I | broadcast input |
| Ctrl+Shift+Q | quit |

Mouse: Ctrl+click opens links, select copies to PRIMARY, middle-click pastes, Alt+click moves the prompt cursor, drag a pane's top bar onto a pane (swap) or a taskbar island (move).

Action names for `keybind`: split_right, split_down, close_pane, equalize_splits, focus_left/right/up/down, copy, paste, new_island, open_settings, jump_prompt_prev/next, command_palette, open_explorer, ssh, increase/decrease/reset_font_size, next_island, previous_island, search, copy_last_output, toggle_split_zoom, toggle_broadcast, search_everything, save_template, new_from_template, close_island, quit, turn_into_note.

## CLI
`jzero -e cmd`, `--working-directory DIR`, `--title T`, `--class NAME` (own window per class), `--toggle` (show/hide the running one). Control commands: `docs/ctl.md`.
