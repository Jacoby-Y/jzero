# JZero shell integration for zsh.
ZDOTDIR="${JZERO_ZDOTDIR:-$HOME}"
unset JZERO_ZDOTDIR
[ -f "$ZDOTDIR/.zshrc" ] && . "$ZDOTDIR/.zshrc"
[ -n "$JZERO_BIN" ] && PATH="$JZERO_BIN:$PATH"  # `0` (JZero commands), `jzctl`
autoload -Uz add-zsh-hook
__jzero_precmd() { local s=$?; printf '\033]133;D;%s\007\033]7;file://%s%s\007\033]133;A\007' $s "$HOST" "$PWD"; }
__jzero_preexec() { printf '\033]633;E;%s\007\033]133;C\007' "$1"; }
add-zsh-hook precmd __jzero_precmd
add-zsh-hook preexec __jzero_preexec
