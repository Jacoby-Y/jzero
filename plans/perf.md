# Performance + real-window checks

Measure in a real window against Ghostty, Alacritty, kitty; headless numbers don't count.

- [ ] Throughput: time `cat` of a 100 MB text file
- [ ] Input latency: keypress to pixel (e.g. typometer)
- [ ] Idle: CPU near 0% with 3 islands open and nothing happening
- [ ] Memory: RSS per pane at 10k scrollback lines
- [ ] Startup: time to the first prompt

Untested in a real setup:
- [ ] IME (fcitx5/ibus): preedit + candidate rect
- [ ] `background-opacity` below 100 in a real compositor
