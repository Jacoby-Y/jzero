# Windows port

Goal: JZero runs fully on Windows 10 1809+ (x86_64-pc-windows-gnu). Linux behavior is unchanged.

j3c now has Windows backends for `j3.term.pty` (ConPTY), `j3.io.watch`, `j3.proc`, `j3.instance` (named pipe)
and `j3.game.hotkey`. Everything left is JZero-side.

## Rules
- One place per OS difference: a small `src/platform/` module (shell, paths, open, notify, font lookup) that
  branches on `sys.PLATFORM` once. Callers never test the platform themselves.
- Paths: build them with one join helper; never hardcode `/`.
- Keep the Linux code paths as they are; Windows adds a branch next to each one.

## 0. Prereq
- [x] `j3c check` fails on Linux right now: import cycle `explorer.explorer -> explorer.ops -> explorer.explorer`
      (files edited 2026-11-16 11:24, looks like in-progress work). Fix that first.
- [x] Cross-build: `[emit] target = ["x86_64-unknown-linux-gnu", "x86_64-pc-windows-gnu"]` (check the host triple
      name with `j3c help manifest`). `[link] libs` "GL" → check whether the Windows target needs `opengl32`.

## 1. Build + boot (no terminal yet)
- [x] Links for Windows; `wine target/x86_64-pc-windows-gnu/jzero.exe --help` prints.
- [x] `src/platform/paths.j3`: data dir `%APPDATA%\jzero` (or `j3.data.save.userDir`), config dir
      `%APPDATA%\jzero\config`, home `%USERPROFILE%`. Replace `HOME`/`XDG_*` in `session/paths.j3`,
      `config/config.j3`, `state/panes.j3`, `features/ssh.j3`.
- [x] `tilde` display: `%USERPROFILE%` → `~`.

## 2. Terminal panes
- [x] `term/reader.j3`: replace `sys.pollFds` on `r.fd` with `Pty.waitReadable(POLL_MS)` (all platforms).
- [x] `term/session.j3` default shell (VS Code's order): Linux `$SHELL` → `/bin/bash`; Windows `pwsh.exe` →
      `powershell.exe` → `%COMSPEC%` (cmd). Config `shell` still overrides.
- [x] Detected shells (`src/platform/shells.j3`): the default above plus cmd, Git Bash
      (`%ProgramFiles%\Git\bin\bash.exe`, only when present) and each WSL distro (`wsl.exe -l -q`, run as
      `wsl.exe -d <name>`). Shown in the new-pane/launcher pick list; Linux lists `/etc/shells` entries or just `$SHELL`.
- [x] `term/procinfo.j3` (`/proc` cwd + foreground program): Windows returns "unknown"; close confirmation
      falls back to "ask when the shell is not at a prompt" using OSC 133 state. Tracks cwd through OSC 7 only.
- [ ] Check ConPTY quirks against the parser: it re-renders the screen and can emit its own cursor/clear
      sequences; check resize reflow, alt screen (vim/htop-alikes), mouse reporting, bracketed paste.

## 3. Shell integration
- [x] `term/shellsetup.j3`: Git Bash reuses the bash snippet (paths converted to `/c/...`); WSL panes get no
      integration at first (OSC 7 from inside WSL gives Linux paths; map `/mnt/c/...` later).
- [x] `term/shellsetup.j3`: add PowerShell (`assets/shell/jzero.ps1`: OSC 7, 133 A/C/D, 633;E via `prompt` +
      PSReadLine hook) started with `-NoExit -Command ". '<path>'"`. cmd.exe: OSC via `PROMPT` env (cwd + prompt
      marks only).
- [x] `0` and `jzctl` commands: `bin/0.cmd`, `bin/jzctl.cmd` (or `.ps1`), on `PATH` per shell; `chmod` step
      skipped on Windows. `jzctl` re-exec: `jzero.exe` with a `--ctl` flag in place of the argv[0] trick
      (works on both; drop argv[0] sniffing if it's simpler).
- [x] `<config>/commands.sh` for `0`: Windows uses `commands.ps1`.
- [x] `state/launch.j3` `jzctl serve` pane: drop the `bash -c` wrapper for a plain argv on Windows.

## 4. Desktop glue
- [x] Open links/files (`features/links.j3`): `xdg-open` → `cmd /c start "" <uri>` (or `explorer.exe <uri>`).
- [x] Notifications (`features/notify.j3`): `notify-send` → PowerShell toast one-liner; silent no-op when that fails.
- [x] `$EDITOR` (`state/panes.j3`): `sh -c` → run `%EDITOR%` directly, else `notepad.exe`.
- [x] Fonts (`term/fonts.j3`): `fc-match` → look in `%WINDIR%\Fonts` and `%LOCALAPPDATA%\Microsoft\Windows\Fonts`
      by file name; CJK/emoji fallbacks: `msyh.ttc`, `seguiemj.ttf`.
- [ ] Global toggle hotkey: `j3.game.hotkey` works as is; check `Taken` is shown.
- [ ] Single instance + `--toggle`/`--new-island`: `j3.instance` works as is; check under a real login.
- [ ] Clipboard/OSC 52, drag-out to other apps, see-through window (`background-opacity`): check each, note what
      SDL does differently on Windows.

## 5. Explorer
- [x] Paths with `\` and drive letters (`C:\`): tree root, breadcrumbs, `..`, rename validation (`ops.j3:160`
      also rejects `\ : * ? " < > |`), hidden files (`.` prefix + hidden attribute if j3 exposes it).
- [ ] git status (`git/`, `explorer/explorer/git.j3`): needs `git.exe` on PATH; `env GIT_TERMINAL_PROMPT=0` in
      `git/repo/ops.j3` → pass the env through `proc` instead of the `env` program.
- [x] Watches (`j3.io.watch`) on folders and the open file.
- [x] SDL2_image for JPG/WebP/GIF/SVG: ship `SDL2_image.dll` in the zip.

## 6. Ship
- [x] `[dist] build_outputs` zip for Windows (DLLs bundled by j3c); `.deb` stays Linux-only.
- [ ] App icon in the `.exe` + Start menu shortcut: zip only for now; installer (MSI/Inno) later if wanted.
- [x] README: Windows install + requirements (Win10 1809+, git optional).

## Open (2026-11-17)
- Unticked boxes above need a real Windows machine (wine has no ConPTY/GL window here). Nothing has run on real
  Windows yet: PowerShell scripts (`jzero.ps1`, `zero.ps1`), toasts, recycle bin, fonts are untested.
- Paths: kept with `/` inside JZero on Windows (`C:/Users/me`), converted at the edges in `platform/os.j3`
  (instead of a join helper everywhere).
- j3c gaps: fixed 2026-11-19 (removeDir, cwd, proc env, monotonic clock).
- Not done: explorer drive switching (up stops at `C:/`), LAN IP for `jzctl serve` (`hostname -I`), hidden
  file attribute, exe icon, WSL shell integration.

## Testing
- `JZERO_SELFTEST=1` self-checks pass on both targets (path join, tilde, shell pick).
- Wine: boots, prints, and runs self-checks; it can't capture windowed frames (SDL offscreen has no GL there).
- Real Windows (VM): pwsh + cmd panes, splits, resize, vim-style full-screen app, explorer on `C:\`, git status,
  `jzctl ls`, `0`, toggle hotkey, restart restores islands. Add a Windows column to `plans/perf.md`.

## Decisions
- Default shell order and extra shells follow VS Code: pwsh → powershell → cmd; Git Bash and WSL distros offered
  when found.
- `ssh` action: Windows' built-in OpenSSH (`ssh.exe`); `~/.ssh/config` read from `%USERPROFILE%\.ssh\config`.
