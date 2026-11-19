# `jzctl` control command

Goal: from any pane, a process (mainly an AI agent) can list panes, open panes, read them, and type into them — no computer use.

Status: implemented. Client `src/features/ctl.j3`, server `src/state/ctl.j3`, over `j3.instance.request` / `App.onRequest`.

## CLI
`jzctl` lives in `assets/shell/bin/jzctl` (on every JZero shell's PATH): it runs `$JZERO_EXE --ctl ...` (`jzctl.cmd` on Windows), which makes the binary a client; plain `jzero ls` launches the app.
`jzctl help` / `jzctl help <cmd>` / `jzctl <cmd> --help` print help locally (`src/features/ctlhelp.j3`), no running JZero needed.
```
jzctl ls [--json]                           # id  island  *|-  program  cwd   (tab-separated; json adds `wants`)
jzctl new split|island [--in <id>] [-- cmd] # prints new pane id
jzctl run <id> <cmd> [--timeout <ms>]       # at the prompt: type, Enter, wait for it; prints output, exits with its code
jzctl send <id> <text> [--enter]            # bracketed paste, Enter as a separate key
jzctl key <id> enter|tab|esc|backspace|up|down|left|right|delete|ctrl+<letter>
jzctl read <id> [--lines N] [--json]        # screen, or last N lines incl. scrollback
jzctl watch <id> [--lines N]                # streams finished lines (long-poll `--from <line>` loop in the client)
jzctl wait <id> (--match <text> | --idle <ms> | --prompt) [--timeout <ms>]
jzctl status <id> [--json]                  # running|idle  exit  ms  command
jzctl history <id> [--lines N] [--json]     # commands, oldest first
jzctl search <text> [--max N] [--json]      # id  island  cmd|out  line   (every pane, closed islands too)
jzctl open <path>[:line] [--in <id>]        # explorer pane beside; prints its id
jzctl notify <text> [--title T]             # desktop notification
jzctl badge <id> [text]                     # label on the pane until the user types there; no text clears
jzctl focus <id>
jzctl close <id> [--force]                  # refuses while a program runs / unsaved edit
jzctl serve [--port N] [--bind IP]          # phone page (docs/remote.md); runs in the client
jzctl kanban ls|show <board> [--json]       # boards; columns + cards numbered
jzctl kanban new|rm|rename <board> [new]
jzctl kanban col add|rename|rm|mv <board> ...   # <col>: number or exact name
jzctl kanban card add|edit|rm|mv <board> <col> ...  # <card>: number in its column
```
- `<id>` is the stable pane id; `self` = `$JZERO_PANE`. `new split` without `--in` splits the asking pane, else the focused one.
- Every shell gets `$JZERO_PANE` and `$JZERO_INSTANCE` (which running copy to talk to: class / `-dev`).
- Exit codes: 0 ok, 1 error (stderr), 2 JZero not running, 3 wait timed out; `run` exits with the command's code.
- Replies: `ok|err|timeout|exit <code>\n<body>`. Server: `state/ctl.j3` (route + actions), `ctlinfo.j3` (printing ones), `ctlwait.j3` (wait/run/watch, answered per frame), `kanban/kanbanctl.j3` (kanban).
- `run`, `status`, `wait --prompt` need shell integration (OSC 133).
- `--match` is a plain substring of the screen (no regex in J3).
- Auth: any same-user process (the instance socket is same-user only).

Example:
```
p=$(jzctl new split -- claude)
jzctl wait $p --match '>' && jzctl send $p '/rc' --enter
```

Headless test: run the server with `JZERO_CTL=<name> SDL_VIDEODRIVER=offscreen`, the client with `JZERO_INSTANCE=<name>` (sandbox `XDG_DATA_HOME`).
