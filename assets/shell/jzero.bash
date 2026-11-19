# JZero shell integration for bash (loaded with --rcfile; sources ~/.bashrc first).
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
[ -n "$JZERO_BIN" ] && PATH="$JZERO_BIN:$PATH"  # `0` (JZero commands), `jzctl`
__jzero_precmd() {
    local s=$?
    printf '\033]133;D;%s\007\033]7;file://%s%s\007\033]133;A\007' "$s" "$HOSTNAME" "$PWD"
    return $s
}
__jzero_preexec() {
    local c
    c="$(HISTTIMEFORMAT= builtin history 1)"
    c="${c#"${c%%[![:space:]]*}"}"
    c="${c#*[[:space:]]}"
    c="${c#"${c%%[![:space:]]*}"}"
    printf '\033]633;E;%s\007\033]133;C\007' "$c"
}
PROMPT_COMMAND="__jzero_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
PS0='$(__jzero_preexec)'"${PS0}"
