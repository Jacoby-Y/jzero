# Remote (phone)

Goal: from a phone, see a running JZero's panes, read them, and type into them (Claude sessions, quick commands).

Status: implemented. `src/remote/serve.j3` + `assets/remote/index.html`.

## Use
- Palette → "Remote access (phone)" (`remote_access`): opens a "Remote" island running `jzctl serve`; close the island to stop. Or run `jzctl serve [--port 7771] [--bind 0.0.0.0]` in any pane.
- It prints a QR code and `http://<ip>:7771/#<token>` (ip: `tailscale ip -4`, else the first of `hostname -I`); scan it with the phone camera. QR from the `qr` package (j3-qr, j3.toml).
- Page: pane list (terminal panes of open islands; "needs you" = a bell/notification or `jzctl badge` not answered yet), tap one → its screen (1 s refresh; "Screen"/"History" = last 500 lines), a key row (Enter Esc Tab ^C arrows ⌫ ^D 1 2 3 y n), a text box (Send = text + Enter, Type = text only), `+` = new shell island.

## How
- `jzctl serve` is its own process, a `jzctl` client: `POST /ctl` with a JSON array of args (`["read","3","--json"]`) → `j3.instance.request` → the same `state/ctl*.j3` handlers. Reply = the raw `ok|err\n<body>`.
- Allowed remotely: ls read send key status history new focus. No run/wait/watch: one connection at a time, so nothing may block.
- `ls --json` has `wants` (Session.wants: set on bell / OSC 9 / 777, cleared by typing or `send`/`key`).

## Security
- Off unless started. A new 128-bit token per run, in the URL fragment (never sent in a GET), sent as `X-Token`; 403 without it.
- Plain HTTP: the token is readable on the network. Home LAN or Tailscale only, never port-forwarded. `--bind <tailscale ip>` keeps it off the LAN.
- Claude Code rings the bell when it waits if its notification channel is `terminal_bell`.
