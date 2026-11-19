# JZero

A lightweight, fast, all-in-one terminal emulator for Linux and Windows. Ghostty-like core, islands instead of tabs, and a built-in file explorer and editor. Written in J3.

- **Islands**: workspaces of split panes, no tmux needed. Close one and it comes back later with its layout, folders, scrollback and history.
- **Explorer pane**: file tree, editor with syntax colors, markdown preview, images, git status.
- **Command palette** (`Ctrl+Shift+P`), search across every pane, ssh, notes, kanban boards.
- **Scriptable**: `jzctl` lists, opens, reads and types into panes from any shell or AI agent; a phone page (`jzctl serve`) does the same from your pocket.
- **Yours**: one config file with hot reload, a settings screen that edits the same file, Ghostty / base16 / iTerm2 themes.
- **Quiet**: fast startup, near-zero CPU and GPU when idle.

## Install

### Linux (Debian, Ubuntu, Pop!_OS, Mint)

```sh
wget https://github.com/jacoby-y/jzero/releases/latest/download/jzero_amd64.deb
sudo apt install ./jzero_amd64.deb
```

Then open **JZero** from your app menu, or run `jzero`.

### Windows (10 version 1809 or newer)

1. Download [jzero-windows-x86_64.zip](https://github.com/jacoby-y/jzero/releases/latest/download/jzero-windows-x86_64.zip).
2. Unzip it anywhere.
3. Run `jzero.exe` in the `jzero` folder.

Nothing else to install. It starts PowerShell 7, Windows PowerShell or cmd, whichever it finds first; Git Bash and WSL show in the command palette as "Shell: ...". Install [Git](https://git-scm.com/download/win) if you want git status in the explorer.

> The Windows build is new and has had little testing on real machines. Please open an issue for anything that breaks.

### From source

Needs the J3 compiler (`j3c`), SDL2, SDL2_ttf and SDL2_image.

```sh
j3c build --release   # packages land in target/dist/
```

## First steps

- `Ctrl+Shift+P`: command palette, everything is in there.
- `Ctrl+Shift+O`: split the pane.
- Settings and every key: [docs/config.md](docs/config.md).

## Goals
- Fast startup, near-zero idle CPU/GPU (sleep until input or pty data).
- Islands + splits built in, no tmux needed. Islands live on the ocean; open = shells running, closed = saved and restored (layout, cwd, scrollback, history).
- Config file + settings screen editing the same file (hot reload).
- Linux (X11 + Wayland) and Windows 10 1809+ (ConPTY).

## Not doing (yet)
macOS, Windows installer (zip only), detach daemon, Sixel, smooth scroll, cursor glide, blur, light/dark auto, vim copy mode, own SSH host store, leader key, paste protection, rerun-last-command, taskbar on other edges.

## Docs
- `CODEMAP.md`: where code lives.
- `docs/config.md`: config keys, keybinds, CLI flags.
- `docs/ctl.md`: `jzctl ls/new/send/...` control command.
- `docs/remote.md`: phone page (`jzctl serve`).
- `docs/extensions.md`: j2 extension panes (TUI apps in a pane).
- `GOTCHAS.md`: J3 lessons learned.
- `plans/`: open work.

## Checks
`j3c check`; `j3c build && JZERO_SELFTEST=1 ./target/x86_64-unknown-linux-gnu/jzero` (logic self-checks; the Windows build runs them under wine: `target/x86_64-pc-windows-gnu/jzero.exe`); headless screenshots driven by `JZERO_ACTIONS` / `JZERO_UI` (dev builds, `src/devhook.j3`).

## License
MIT, see `LICENSE`. Bundled fonts keep their own licenses (JetBrains Mono Nerd Font: SIL OFL).
