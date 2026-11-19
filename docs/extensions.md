# Extensions

An extension is a small app in its own pane, written in j2 (a scripting language like J3 with
Lua-style values; language page: `j3c doc j2 lang`). JZero reads it at runtime: no rebuild.

- Folder: `~/.config/jzero/extensions/<name>/main.j2`.
- Open: Command palette → `Extension: <title>`. It replaces the focused pane, or splits right when
  that pane is busy (a program running, unsaved editor edits). The pane is saved with the island
  and reopens fresh, keeping only `pane.saved`.
- Saving `main.j2` reloads it; its open panes start over (keeping `pane.saved`). Palette `Reload extensions` reloads all
  (and finds new folders); `Open extensions folder` opens it in an explorer pane.
- A `syntax/` folder adds editor grammars (docs/syntax.md); a folder with only that is not a pane.
- An error shows in red in its pane; the other panes keep running.
- Examples: `assets/ext/examples/todo/main.j2` (list, keys), `assets/ext/examples/jfishy/main.j2`
  (buttons, `pane.saved`), `assets/ext/examples/mousetracker/main.j2` (`move`),
  `assets/ext/examples/particletester/main.j2` (`click`, `tick` animation, `pane.menu`),
  `assets/ext/examples/terminalmeasure/main.j2` (`pane.cols`/`rows`, redrawn on resize).

## Hooks (all optional)

`pane` is one table per open pane: `pane.cols`, `pane.rows` (size in cells), `pane.every`
(set it to get `tick` every N ms), `pane.menu` and `pane.saved` (below), and any fields you add.

`pane.menu` adds entries to the top of the right-click menu while the pane is focused: an array of
`{ label, f }`; picking one calls `f(pane)`, then `draw`. Set or change it anytime.

    pane.menu = [{ label: "Reset", f: fn(p) { p.saved.count = 0; } }];

`pane.saved` is kept when JZero restarts and when the script reloads: nil, bools, numbers,
strings, arrays, and tables with name keys (`{ hp: 3 }`); functions and other keys are dropped.
Every other field starts over. It is written when the pane stops and deleted with the pane.

    pub fn open(pane) { if pane.saved == nil { pane.saved = { count: 0 }; } }

| fn | called |
|---|---|
| `open(pane)` | once, when the pane opens |
| `key(pane, k)` | a key: `"a"`, `"A"`, `" "`, `"enter"`, `"up"`, `"f5"`, `"ctrl+c"`, `"alt+x"`, `"shift+tab"` |
| `paste(pane, text)` | pasted text |
| `click(pane, col, row, button)` | a mouse press (0 left, 1 middle, 2 right, 4/5 wheel) not on a `tui.button`; defining it turns the mouse on |
| `move(pane, col, row)` | the pointer moved to another cell (with or without a button held); defining it turns motion reports on |
| `resize(pane)` | the size changed |
| `tick(pane)` | every `pane.every` ms |
| `draw(pane)` | after `open` and after any of the above: draw the whole screen |

`pub let title = "Name";` names it in the palette (default: the folder name).

## Drawing

The pane is a full-screen terminal screen. Colors are the theme's 16 slots (0..15, -1 default),
so they follow the theme.

| fn | does |
|---|---|
| `clear()` | blank screen, cursor at 0,0 |
| `at(col, row)` | move the cursor (0-based) |
| `write(text)` | text at the cursor, cut at the right edge (`"\n"` goes to the next line) |
| `color(fg, bg)` | colors for what follows |
| `bold(on)` `invert(on)` `reset()` | style |
| `cursor(on)` | show the text cursor (hidden by default) |
| `width(text)` `cut(text, cols)` | columns a text takes; its first `cols` columns. Measure with `width`, not `len` (bytes) |

`use tui;` adds helpers: `tui.text(x, y, s, fg, bg)`, `tui.fill(x, y, w, h, bg)`,
`tui.box(x, y, w, h, title, fg)`, `tui.list(x, y, w, h, items, sel, top)`,
`tui.scrollTo(sel, top, h)`, `tui.bar(pane, row, s)`, `tui.fit(s, w)`, `tui.rep(s, n)`,
`tui.button(pane, x, y, label, f)`, and color names (`tui.GREEN`, `tui.GRAY`, ...).

`tui.button` draws `[ label ]` and returns its width; a left click on it calls `f(pane)`, then
`draw`. Call it from `draw` (buttons are rebuilt each draw); it turns the mouse on.

    pub fn draw(pane) {
        clear();
        let x = 1;
        x += tui.button(pane, x, 0, "More", fn(p) { p.saved.count += 1; }) + 1;
        tui.text(x, 0, str(pane.saved.count), -1, -1);
    }


## Other

`close()` closes the pane, `notify(title, body)` sends a desktop notification,
`clipboard(text)` copies, `ms()` is a millisecond clock, `print(...)` writes to JZero's stdout.
Scripts can't reach files, processes or the network.

## Testing an extension (headless, dev build)

Sandbox both folders: JZero loads extensions from `$XDG_CONFIG_HOME/jzero/extensions` and saves
islands (and `pane.saved`) to `$XDG_DATA_HOME/jzero`. Never run against the real ones. Use a fresh
data folder for each run: every run saves its islands, so a reused one gains another extension
pane each time and the click positions shift.

    S=<scratch dir>
    rm -rf $S/data && mkdir -p $S/data $S/cfg/jzero/extensions
    cp -r path/to/NAME $S/cfg/jzero/extensions/
    XDG_DATA_HOME=$S/data XDG_CONFIG_HOME=$S/cfg J3_IDLE_SKIP=1 \
      JZERO_ACTIONS="island:0,ext:NAME" JZERO_UI="30:xy:X:Y,40:text:c" \
      timeout 120 j3c run --frames 60 --screenshot $S/shot.png --headless

- `ext:NAME` opens the extension like the palette does (`JZERO_ACTIONS`, frame 5 on).
- `JZERO_UI` items are `frame:what`: `xy:X:Y` / `rxy:X:Y` click, `wheel:X:Y:N` scrolls,
  `text:abc` types (keys reach the focused pane, which is the extension pane),
  `key:ctrl+c` presses a combo. Spread them over frames (`30:...,40:...`) so each one is drawn before the next.
- `X:Y` are window pixels. Run once without clicks, read the button's position off the
  screenshot (it is window size: 1 image pixel = 1 window pixel), then click there.
- Errors show in red in the pane, so check the screenshot. A temporary `print(pane.cols, pane.rows)`
  in `draw` shows the size on stdout.
- `pane.saved` is in `$S/data/jzero/ext/<pane id>`: run again on the same data folder (no
  `ext:` action) to check it comes back.
