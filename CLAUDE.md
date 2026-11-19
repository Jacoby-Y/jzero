@AGENTS.md

# CLAUDE.md

## Project
JZero: lightweight, fast, all-in-one Linux terminal emulator (Ghostty-like, islands/ocean, built-in explorer). Overview: README.md. J3 gotchas: GOTCHAS.md.
Stack: J3 (j3c, LLVM backend), SDL2 + SDL2_ttf + GL, `.j3ui` UI.

## Rules
- Be as concise as possible. Respond with as little as possible.
- After implementing: reply `Done` + concise list of what was implemented.
- Don't implement unless explicitly told. Often you'll be asked to look and give an overview, NOT fix yet. Overview first is always better.
- Don't assume. Ask concise questions. First option = your recommendation for best style/scalability, even if harder.
- Treat this as a massive project: organized, scalable, extensible.
- Split files past a few hundred lines.
- Keep CODEMAP.md concise and up to date.

## UI
- No border radius, border colors, gradients, or box shadows.
- Simple colors. Easy to read and navigate.
- Default palette: classic GNOME Terminal colors (Tango). Themes must be swappable later — keep every color in theme tokens, never hardcode.
