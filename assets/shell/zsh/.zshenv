# JZero shell integration for zsh: ZDOTDIR points here; load the user's files from their own.
__jzero_dir="$ZDOTDIR"
ZDOTDIR="${JZERO_ZDOTDIR:-$HOME}"
[ -f "$ZDOTDIR/.zshenv" ] && . "$ZDOTDIR/.zshenv"
ZDOTDIR="$__jzero_dir"
