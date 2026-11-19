# JZero commands on Windows: one PowerShell file of functions, one function per command.
#   0                 list commands
#   0 <name> [args]   run one
#   0 0               edit the file (%EDITOR%, else Notepad)
# `split` and `island` commands ask JZero (OSC 7770 with this shell's JZERO_TOKEN) to open a
# pane that runs `0 --pane <name> [args]`. Outside JZero they run inline.
# Run by `0.cmd`; Git Bash uses the bash `0` beside it (and its own commands.sh).
$f = Join-Path $env:APPDATA 'jzero\config\commands.ps1'
$rest = @($args)
$tab = "`t"

$template = @'
# JZero commands: `0 <name> [args]` runs function <name>; `0` lists them; `0 0` edits this file.
#
# One PowerShell function per command. The first comment line right above a function is its
# description. `# @run <mode>` among those lines picks where it runs:
#   inline  (default) in the current terminal
#   split   in a new pane beside it
#   island  in a new island
#   bg      in the background; a desktop notification says when it is done
# Functions starting with `_` are helpers and are not listed. Arguments arrive as $args.
# This file is sourced fresh on every run.

# Say hello
function hello {
    $who = if ($args.Count -gt 0) { $args[0] } else { 'world' }
    "hello $who from $PWD"
}
'@

# One `name<TAB>mode<TAB>description` line per command, in file order.
function __ZeroCommands {
    $desc = ''
    $mode = ''
    foreach ($l in Get-Content -LiteralPath $f) {
        if ($l -match '^\s*#\s?(.*)$') {
            $c = $Matches[1]
            if ($c -match '^@run\s+(\S+)') { $mode = $Matches[1] } elseif ($desc -eq '') { $desc = $c }
            continue
        }
        if ($l -match '^\s*function\s+([A-Za-z0-9][A-Za-z0-9_-]*)') {
            if ($mode -eq '') { $mode = 'inline' }
            $Matches[1] + $tab + $mode + $tab + $desc
        }
        $desc = ''
        $mode = ''
    }
}

# Source the file and call function $a[0] with the rest; its exit code lands in $script:__ZeroCode.
function __ZeroRun($a) {
    . $f
    $n = $a[0]
    $more = @($a | Select-Object -Skip 1)
    $global:LASTEXITCODE = 0
    & $n @more
    $script:__ZeroCode = if ($?) { $global:LASTEXITCODE } elseif ($global:LASTEXITCODE) { $global:LASTEXITCODE } else { 1 }
}

# JZero's completion list (`features/zerocmds.j3`): the raw lines, nothing created.
if ($rest.Count -gt 0 -and $rest[0] -eq '--list') {
    if (Test-Path -LiteralPath $f) { __ZeroCommands }
    exit 0
}

if (-not (Test-Path -LiteralPath $f)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $f) | Out-Null
    Set-Content -LiteralPath $f -Value $template -Encoding UTF8
}

if ($rest.Count -eq 0) {
    "JZero commands ($f):"
    foreach ($l in __ZeroCommands) {
        $p = $l -split $tab
        $m = if ($p[1] -eq 'inline') { '' } else { "  [$($p[1])]" }
        '  {0,-16} {1}{2}' -f $p[0], $p[2], $m
    }
    ''
    '0 <name> [args] runs one; 0 0 edits the file.'
    exit 0
}

if ($rest[0] -eq '0') {
    $ed = if ($env:EDITOR) { $env:EDITOR } else { 'notepad.exe' }
    $parts = @($ed -split ' ' | Where-Object { $_ })
    $edArgs = @($parts | Select-Object -Skip 1) + $f
    & $parts[0] @edArgs
    exit $LASTEXITCODE
}

if ($rest[0] -eq '--pane') {  # JZero's split / island pane: run, then hold the pane open until Enter
    $a = @($rest | Select-Object -Skip 1)
    __ZeroRun $a
    [Console]::Write("`n[$($a[0]) exited $script:__ZeroCode, press Enter to close]")
    [void][Console]::ReadLine()
    exit $script:__ZeroCode
}

if ($rest[0] -eq '--bg') {  # the hidden copy `bg` starts: run into the log, then say so
    $log = $rest[1]
    $a = @($rest | Select-Object -Skip 2)
    __ZeroRun $a *> $log
    if ($env:JZERO_EXE) { & $env:JZERO_EXE --ctl notify "0 $($a[0]) finished (exit $script:__ZeroCode)" | Out-Null }
    exit $script:__ZeroCode
}

$errs = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$null, [ref]$errs)
if ($errs -and $errs.Count -gt 0) {
    [Console]::Error.WriteLine("0: $f has a syntax error (0 0 to fix it)")
    exit 2
}
$name = $rest[0]
$line = __ZeroCommands | Where-Object { ($_ -split $tab)[0] -eq $name } | Select-Object -First 1
if (-not $line) {
    [Console]::Error.WriteLine("0: no command '$name' (0 lists them, 0 0 edits them)")
    exit 127
}
$mode = ($line -split $tab)[1]

if (($mode -eq 'split' -or $mode -eq 'island') -and $env:JZERO_TOKEN) {
    $s = "$([char]27)]7770;$($env:JZERO_TOKEN);$mode"
    foreach ($a in $rest) { $s += ';' + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes([string]$a)) }
    [Console]::Write($s + [char]7)
    exit 0
}

if ($mode -eq 'bg') {
    $log = Join-Path $env:TEMP "jzero-0-$name.log"
    $quoted = @($PSCommandPath, '--bg', $log) + $rest | ForEach-Object { '"' + (([string]$_) -replace '"', '\"') + '"' }
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File') + $quoted)
    "0: $name running in the background (log: $log)"
    exit 0
}

__ZeroRun $rest
exit $script:__ZeroCode
