# JZero shell integration for fish (loaded with --init-command).
set -q JZERO_BIN; and set -gx PATH $JZERO_BIN $PATH  # `0` (JZero commands), `jzctl`
function __jzero_prompt --on-event fish_prompt
    printf '\e]133;D;%s\a\e]7;file://%s%s\a\e]133;A\a' $status (hostname) $PWD
end
function __jzero_preexec --on-event fish_preexec
    printf '\e]633;E;%s\a\e]133;C\a' "$argv"
end
