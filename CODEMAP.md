# CODEMAP
JZero: Linux terminal emulator in J3. Islands (named split layouts of panes) on an ocean; panes are shells or file explorers; everything saved and restored.

## Structure
```
j3.toml              package + [dist] zip/deb
README.md            goals, not-doing, doc index
GOTCHAS.md           J3 lessons learned
docs/config.md       config keys, default keys, CLI flags
docs/ctl.md          `jzctl` control command for agents (ls/new/run/read/watch/wait/status/history/search/open/notify/badge/kanban/...)
docs/remote.md       `jzctl serve`: phone page (read/type into panes over LAN/Tailscale)
docs/extensions.md   writing j2 extensions (hooks, drawing natives, `tui`)
docs/syntax.md       `.syntax` grammar format (bundled + extension grammars)
plans/               open work (perf.md: real-window checks; windows.md: Windows port)
tools/icons.html     icon preview page
assets/font.ttf      UI font
assets/mono.ttf      terminal font (JetBrains Mono Nerd Font Mono); mono-italic.ttf its italic
assets/ext/tui.j2    bundled j2 drawing helpers (`use tui;`, `tui.button`); assets/ext/examples/ todo, jfishy, mousetracker, particletester, terminalmeasure sample extensions
assets/syntax/       bundled `.syntax` grammars (J3/j3s, j2, C, Rust, Go, Python, JS/TS, Java, Lua, Ruby, shell, SQL, Make, Docker, HTML/XML, CSS, JSON, TOML, YAML, INI, ignore files, generic fallback)
assets/remote/index.html phone page (embedded in the binary)
assets/shell/        shell integration snippets (bash, zsh, fish, PowerShell `jzero.ps1`); copied to the data dir
assets/shell/bin/0   `0` command (on each shell's PATH): runs functions from <config>/commands.sh; `0` lists, `0 0` edits; Windows: `0.cmd` → `zero.ps1` (commands.ps1)
assets/shell/bin/jzctl `jzctl` control command (on each shell's PATH): runs `$JZERO_EXE --ctl ...` (`jzctl.cmd` on Windows)
                     `# @run split|island` ones ask JZero via OSC 7770 + $JZERO_TOKEN, `bg` ones notify when done
icons/*.svg          custom icons for <icon name> (single-color fills, no strokes)
packaging/           app icon, postinst/prerm (x-terminal-emulator), in the .deb

src/main.j3          entry: App (see-through, --class), CLI args, keymap poll -> actions, state.update, render; JZERO_SELFTEST=1 runs self-checks
src/state.j3         State: islands, active island, config/themes/fonts, frame update, save islands, per-island zoom
src/state/panes.j3   State part: pane lifecycle (open/stop shells and explorers, shell → explorer in place, splits, ssh, $EDITOR, swap/move panes)
src/state/shells.j3  State part: per-frame shell reports (output badge, bell, OSC 9/777/52, `0` requests, long-command notice), broadcast
src/state/close.j3   State part: close pane/island/quit, asking while a program runs (`ask`)
src/state/launch.j3  State part: `jzero -e/--title/--working-directory`, templates, search-everything gather
src/state/zero.j3    State part: `0` split/island requests → pane running `0 --pane <name> [args]`; findPane/splitPane
src/state/notes.j3   State part: notes view (explorer at config `notes-dir`, default <data>/notes), "Turn into note" picker → shell pane becomes an explorer on that note
src/state/git.j3     State part: Git UI open on the focused pane's folder (`focusedDir`), `gh auth login` in a split
src/state/kanban.j3  State part: kanban view toggle; `viewOpen`/`hideViews` (notes or kanban replaces ocean/island)
src/state/ctl.j3     State part: routes `jzctl` requests (j3.instance request/reply); new/open/send/key/badge/notify/focus/close
src/state/ctlinfo.j3 State part: `jzctl` ls/read/status/history/search (text or --json)
src/state/ctlwait.j3 State part: `jzctl` wait/run/watch, answered per frame (Waiter)
src/kanban/board.j3  Board: columns of cards (title + body), move card/column, `## col` / `- card` / `  body` file text
src/kanban/boards.j3 Boards: board files in <data>/kanban (list, open, new, rename, delete, save when dirty), edit dialog target
src/kanban/kanbanctl.j3 `jzctl kanban ...`: ls/show/new/rename/rm boards, col/card add/rename|edit/rm/mv (any board; open one live)
src/git/repo.j3      Repo: one folder's git state (status v2, branches, log, origin, diff of one file), read on refresh via `git`/`gh`
src/git/repo/ops.j3  Repo part: init, stage/unstage, commit, switch/new branch, diff; push/pull/`gh repo create` on the worker
src/git/job.j3       Job: one program run on a worker thread, polled each frame
src/util/sort.j3     `sort.strings` (byte order)
src/util/resize.j3   Resize: centered modal size dragged from a corner grip (Properties, Git UI)
src/actions.j3       action ids, names/titles, `run`; palette fill + pick; right-click menu list
src/ext/host.j3      extensions: one j2 VM, <config>/extensions/<name>/main.j2 (rescan + mtime reload), a pane instance per
                     EXT pane (keys decoded → `key`, clicks → `tui.button` or `click`, resize, `tick` via pane.every, then `draw`),
                     `pane.saved` kept across reloads/restarts, `pane.menu` → right-click menu entries, errors shown in the pane
src/ext/api.j3       natives scripts call (write/at/color/clear/close/notify/...; write cuts at the right edge), key event → name
src/ext/save.j3      `pane.saved` ↔ j2 literal file (<data>/ext/<pane id>), read back by the VM
src/devhook.j3       dev builds: JZERO_ACTIONS (+JZERO_AT frame) and JZERO_UI (text/tag clicks; real mouse `xy`/`rxy`/`wheel`, real keyboard `text:`/`key:`) for headless checks
src/config/parse.j3  `key = value` parser
src/config/config.j3 Config (font, line-height, padding, theme + color overrides, cursor, dimming, bell, notify, ...), load/save (owned keys, non-defaults only), mtime reload
src/config/draft.j3  Draft: the settings screen's edits; apply (live preview), check (numbers, combos, duplicates), finish (keybinds) for Save
src/input/mods.j3    modifier bits held
src/input/keymap.j3  combo -> action table; defaults + config keybinds
src/input/keynames.j3 key names for config combos (`ctrl+shift+o`)
src/layout/icons.j3  island icon names: `name(i)`, `index(name)`
src/layout/island.j3 Island (name, icon, ocean pos, open, panes, font px, tag, last used, broadcast, temp) + Islands
src/layout/split.j3  split tree per island: Node (leaf: id, cwd, cmds, pane kind TERMINAL/EXPLORER/EXT (cwd = ext name), term/explorer), Panes ops (zoom, swap)
src/term/session.j3  Session: pty + parser + tap + grid + view + selection + search; pump/draw/resize/copy/paste/prompts;
                     `openExt`: no pty, output from `inbox`, input to `keysIn` (extension panes)
src/term/session/    Session parts: draw.j3 (cursor style/blink, marks, search, IME, dim, bell), mouse.j3 (select, drag-past-edge scroll, motion reports to programs,
                     links, Alt+click, file drop), find.j3 (search scroll/refresh), zero.j3 (`0 <name>` top-5 popup, Tab completes)
src/term/search.j3   find in scrollback: matches as cell ranges (case toggle)
src/term/procinfo.j3 /proc: cwd, foreground program (close confirmation); not `available()` on Windows (OSC 7/133 instead)
src/term/reader.j3   worker per session: waits on the pty (`waitReadable`), wakes the idle loop
src/term/selection.j3 text selection in grid line coords (char/word/line)
src/term/linemap.j3  keeps grid line numbers (prompt marks, output range) through a reflowing resize
src/term/shellint.j3 Tap: Sink wrapper reading OSC 7 / 133 A,C,D / 633;E / 9 / 777 / 52 / 7770 (cwd, prompts, exit codes,
                     output range, commands, notifications, clipboard)
src/term/shellsetup.j3 installs snippets, argv/env per shell (bash --rcfile, zsh ZDOTDIR, fish --init-command, PowerShell -NoExit -Command, cmd PROMPT), bin/ on PATH, per-shell $JZERO_TOKEN
src/term/fonts.j3    terminal font + italic (bundled, a path, or a family via platform/fontfiles) + CJK/emoji fallbacks, cached per size
src/theme/theme.j3   bundled palettes + custom (Themes), editor syntax colors (Dark+), colors in use (PAL) with config overrides, version counter
src/theme/files.j3   theme files in <config>/themes: Ghostty, base16 YAML, iTerm2 .itermcolors
src/platform/os.j3   the one place that tests the OS: `windows()`, paths (`/` inside JZero on Windows too: `slashes`/`native`/`fromShell`),
                     home/data/config/temp dirs, `nowMs`, `random`, `appStart` (console, cwd)
src/platform/shells.j3 default shell, detected shells (/etc/shells; pwsh, powershell, cmd, Git Bash, WSL), $EDITOR / `0` / serve argv
src/platform/desktop.j3 open a link or file, notification, trash
src/platform/fileops.j3 copy, move, delete tree, properties (cp/mv/rm/stat on Linux, j3.io on Windows)
src/platform/fontfiles.j3 font family → file (fc-match; Windows Fonts folders), CJK/emoji fallback files
src/session/paths.j3 data dir layout (islands, scroll/, hist/, cmds/, shell/); `tilde` for display
src/session/store.j3 islands file encode/decode
src/explorer/explorer.j3 file tree (lazy, open folders kept, dotfiles toggle) + editor model (open/save/find/replace), drag-out to other apps;
                     shown folders + open file watched (j3.io.watch): tree relists, file reloads (unsaved edits kept)
src/explorer/explorer/git.j3 Explorer part: git status colors
src/explorer/explorer/select.j3 Explorer part: multi-pick (Shift range / Ctrl toggle), double click opens, row info (size / item count), Properties (`stat`)
src/explorer/explorer/test.j3 Explorer part: selfTest
src/explorer/clip.j3 Clip: app-wide file clipboard (State.clip; copy/cut in one explorer, paste in any island)
src/explorer/explorer/view.j3 Explorer part: image modal (open/step/close), markdown preview (task toggle, links), grid (enter folder)
src/explorer/kinds.j3 file kind by extension (TEXT/MARKDOWN/IMAGE): picks the view; a new format = a kind + a view
src/explorer/image.j3 Viewer: one texture, fit/zoom at pointer/pan, checkerboard, info; `sibling` = prev/next image in folder
src/explorer/thumbs.j3 Thumbs: grid thumbnails (loadRgba → shrink to 192px → texture), one per frame, LRU 256
src/explorer/mddoc.j3 Doc: markdown → blocks (heading/para/item+task/quote/code/rule/table row) of inline runs, for the preview (centered HTML blocks, table column align)
src/explorer/mddoc/inline.j3 Doc part: inline runs, nested styles as flags, inline HTML tags, images
src/explorer/mdhtml.j3 HTML tag reader (name, attrs, comments, block tags) for mddoc
src/explorer/ops.j3  new/rename/move, trash (`gio trash`), copy/cut/paste (`cp -a` / `mv`, "name (copy).ext")
src/explorer/highlight.j3 editor syntax colors: kind → theme.syntax (Dark+ default), grammar per file (.md → markdown.j3)
src/explorer/syntax/ grammar.j3 (`.syntax` → Grammar), lex.j3 (Grammar + text → spans), registry.j3 (bundled + extension grammars, 1s rescan)
src/explorer/markdown.j3 markdown styled in place: headings, bold/italic, code/fences, list/quote markers, links, [[wikilinks]]
src/features/links.j3 OSC 8 + plain URL under a cell; opens via platform/desktop
src/features/palette.j3 palette entries, fuzzy filter
src/features/ssh.j3  hosts from ~/.ssh/config
src/features/ctl.j3  `jzctl` client (`jzero --ctl ...` or argv[0] `jzctl`; forwards argv, prints reply, exit code; `watch` loop), instance name, arg/key helpers
src/remote/serve.j3  `jzctl serve`: tiny HTTP server, `assets/remote/index.html` + `POST /ctl` → instance request (token, allowlist); prints the link + QR (`qr` dep), IP from tailscale/hostname
src/features/ctlhelp.j3 `jzctl help [cmd]` / `<cmd> --help` pages (printed locally)
src/features/quick.j3 quick terminal: global hotkey / `jzero --toggle` show-hide, single instance args
src/features/notify.j3 desktop notifications (platform/desktop, detached)
src/features/status.j3 pane status text (exit code, duration)
src/features/zerocmds.j3 JZero command list (from `0 --list`, reloaded on commands.sh change) + top-5 match
src/features/everything.j3 "search everything": every pane's scrollback + commands, open or closed


ui/Screen.j3ui       root: theme class, taskbar + titlebar + ocean or island, overlays
ui/IslandIcon.j3ui   island icon set
ui/taskbar/Taskbar.j3ui   ocean, open islands (unseen-output dot, tag color, pane drop target, drag to reorder, middle-click closes), plus → popover: new island + closed islands by last use, kanban, notes, settings
ui/ocean/Ocean.j3ui       drag islands (snap to icon grid, `oceanSnap`), select, double-click opens, right-click opens Inspector; tag filter, sort by last used, from template
ui/ocean/Inspector.j3ui   right-click popover: rename, icon, tag, open/close/delete, save as template, layout preview with commands
ui/ocean/Ripples.j3ui     backdrop canvas: pointer moves drop ASCII rings (wordmark-sized mono cells, `--ocean-ripple`)
ui/island/TitleBar.j3ui   window-drag bar: title, cwd, split/palette buttons, window controls
ui/island/Island.j3ui     split tree as absolute boxes, divider drag, focus
ui/island/Pane.j3ui       terminal pane: <canvas> drawing the session; drag bar (swap/move), drop target
ui/island/SearchBar.j3ui  find box over a pane (Ctrl+Shift+F)
ui/Confirm.j3ui           "still running" close confirmation
ui/explorer/Explorer.j3ui explorer pane: tree or grid, toolbar, image modal, editor (md: preview/source toggle), find/replace, confirms; `side` = notes view (tree beside editor, autosave, new files .md)
ui/explorer/ImageView.j3ui image modal content (resizable dialog in Explorer.j3ui): canvas (wheel zoom, drag pan), prev/next (Left/Right), fit, 1:1, close
ui/explorer/MdView.j3ui   markdown preview blocks; MdRuns.j3ui inline runs (links via `ex.follow`)
ui/explorer/Grid.j3ui     tiles with thumbnails (canvas per image tile)
ui/menu/ContextMenu.j3ui  right-click menu (actions; "Focus folder" on an explorer folder row)
ui/palette/Palette.j3ui   command palette (Ctrl+Shift+P)
ui/settings/Settings.j3ui settings dialog: sidebar tabs, live preview, Save writes the config, Cancel reloads it
ui/settings/*.j3ui        tabs: Appearance, Colors (overrides per slot), Shell, Behavior, Explorer, Keys (every action's combo); Row = one setting
ui/kanban/Kanban.j3ui     kanban view: board list, columns, cards; drag cards/columns; right-click menu (card/column/board entries)
ui/kanban/Edit.j3ui       edit dialog: card title + body, column or board name, delete
ui/git/GitPanel.j3ui      Git UI modal (click outside closes): init, publish to GitHub / log in, pull/push, changes + stage, commit, branches, diff or history
ui/notes/NotePick.j3ui    "Turn into note" modal: every .md in the notes folder
ui/theme.css         theme tokens: Tango default + .theme-* chrome blocks
```

## Adding features
- A user command: add an action id in `actions.j3` (name, title, `run` arm), a default key in `keymap.j3`; palette and config keybinds pick it up.
- Emulation/logic in `src/<area>/`, one job per file; no UI imports in `term/`.
- Screens/panels as `.j3ui` in `ui/<area>/`, reading state via props.
- Colors only via theme tokens (CSS) or `theme.j3` (terminal).
- Explorer panes save the open file (else the root) as their cwd and reopen it; files under the notes folder autosave.
- A language: a `.syntax` file in `assets/syntax/` (docs/syntax.md).
- An extension hook/native: `ext/api.j3` (bind + doc in docs/extensions.md); host calls in `ext/host.j3`.
- Logic with branches gets a `selfTest` called from `main.j3` (`JZERO_SELFTEST=1 ./target/x86_64-unknown-linux-gnu/jzero`).
