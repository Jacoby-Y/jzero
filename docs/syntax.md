# Syntax highlighting

The explorer editor colors files with grammars: `assets/syntax/*.syntax` (bundled) and
`~/.config/jzero/extensions/<name>/syntax/*.syntax` (an extension; it needs no `main.j2`).
An extension's grammar wins over a bundled one for the same file type. Saving one recolors open
editors within a second; palette `Reload extensions` forces it. Markdown is built in (`markdown.j3`).

Kinds: `comment string number keyword type function constant builtin key section variable annotation control`
(`control`: control flow, `keyword`: declarations. Colors: VS Code Dark+, overridable per kind with `syntax-<kind> = #rrggbb` in the config).

A grammar is `key = value` lines (`#` line = comment):

| key | value |
|---|---|
| `name` | display name |
| `ext` | file extensions, space-separated; `*` = fallback for unclaimed files |
| `file` | exact file names (`Makefile .bashrc`) |
| `comment` | `//` (to end of line) or `/* */` (block), optional flags |
| `string` | `<open> <close> [flags]` |
| `region` | `<kind> <open> <close> [flags]`; close `$` = end of line |
| `<kind>` | words of that kind (`keyword = if else`) |
| `after` | `<kind> word...`: the word after one of these gets `<kind>` (`after = function fn`) |
| `prefix` | `<kind> <text>`: `<text>` plus the word after it (`prefix = annotation @`) |
| `call` | `true`: a word right before `(` is a function |
| `capitalized` | `<kind>` for Capitalized words |
| `plain` | `<kind>` for every other word (`plain = variable`) |
| `key` | `<sep> [anywhere]`: the first word/string on a line before `<sep>` is a key (`anywhere`: any) |
| `word-chars` | extra bytes inside words (`-.`) |
| `ignore-case` | `true`: words match lowercased (list them lowercase) |

Flags: `escape` (`\` skips a byte), `multiline`, `start` (first on its line), `alone` (at a line
start or after a space: `#` in shell), `char` (short, no spaces: `'a'` but not Rust `'a`).

Regions and prefixes are tried in file order: list longer opens first (`"""` before `"`).
Example: `assets/syntax/j3.syntax`.
