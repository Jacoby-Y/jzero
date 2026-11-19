# JZero shell integration for PowerShell (run with -NoExit -Command, after the profile).
if ($env:JZERO_BIN) { $env:PATH = "$env:JZERO_BIN;$env:PATH" }  # `0` (JZero commands), `jzctl`
if ($env:HISTFILE) { try { Set-PSReadLineOption -HistorySavePath $env:HISTFILE } catch {} }

# Each prompt: the last command's exit code (133;D), the directory (OSC 7), prompt start (133;A).
$Global:__JZeroPrompt = $function:prompt
function Global:prompt {
    $ok = $?
    $code = $global:LASTEXITCODE
    $e = [char]27
    $b = [char]7
    $s = 0
    if (-not $ok) { if ($code) { $s = $code } else { $s = 1 } }
    $out = "$e]133;D;$s$b"
    if ($PWD.Provider.Name -eq 'FileSystem') {
        $p = ($PWD.ProviderPath -replace '%', '%25') -replace '\\', '/'
        $out += "$e]7;file://localhost/$p$b"
    }
    $out += "$e]133;A$b"
    $global:LASTEXITCODE = $code
    $out + $Global:__JZeroPrompt.Invoke()
}

# Each command line as it is entered: the text (633;E) and "output starts" (133;C).
# `0` alone is a number to PowerShell, so a line starting with it runs `0.cmd` instead.
if (Get-Command PSConsoleHostReadLine -ErrorAction SilentlyContinue) {
    $Global:__JZeroReadLine = $function:PSConsoleHostReadLine
    function Global:PSConsoleHostReadLine {
        $line = $Global:__JZeroReadLine.Invoke()
        $e = [char]27
        $b = [char]7
        $flat = ([string]$line) -replace "\r?\n", ' '
        [Console]::Write("$e]633;E;$flat$b$e]133;C$b")
        ([string]$line) -replace '^\s*0(?=\s|$)', '& 0.cmd'
    }
}
