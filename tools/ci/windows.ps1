# The Windows checks (see .github/workflows/windows.yml). Every step runs; the exit code says
# whether all passed. Logs and a screenshot go to ci-out/.
$root = (Get-Location).Path
$out = Join-Path $root 'ci-out'
New-Item -ItemType Directory -Force $out | Out-Null
$script:failed = @()
function Step($name, [scriptblock]$body) {
    Write-Output "::group::$name"
    try { & $body; Write-Output "PASS $name" }
    catch { Write-Output "FAIL $name`: $_"; $script:failed += $name }
    Write-Output "::endgroup::"
}
function Need($ok, $what) { if (-not $ok) { throw $what } }

gh release download ci --repo $env:GITHUB_REPOSITORY -p jzero-ci-windows.zip
Expand-Archive jzero-ci-windows.zip -DestinationPath .
$app = Join-Path $root 'jzero'
$exe = Join-Path $app 'jzero.exe'
Set-Location $app

Step 'self-checks' {
    $env:JZERO_SELFTEST = '1'
    $text = (& $exe 2>&1 | Out-String)
    $env:JZERO_SELFTEST = $null
    $text | Set-Content (Join-Path $out 'selftest.txt')
    Write-Output $text
    Need ($text -match 'selftest ok') 'no "selftest ok"'
}

$scripts = @('assets\shell\jzero.ps1', 'assets\shell\bin\zero.ps1')
Step 'scripts parse (pwsh 7)' { pwsh -NoProfile -File "$root\tools\ci\parse.ps1" @scripts; Need ($LASTEXITCODE -eq 0) 'syntax errors' }
Step 'scripts parse (Windows PowerShell 5.1)' { powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$root\tools\ci\parse.ps1" @scripts; Need ($LASTEXITCODE -eq 0) 'syntax errors' }

Step 'help prints' {
    $text = (& $exe --ctl help 2>&1 | Out-String)
    Need ($text -match 'jzctl ls') 'no help text'
}

# The runner has no GPU: Mesa's software OpenGL next to the exe.
Step 'software OpenGL' {
    $rel = gh api repos/pal1000/mesa-dist-win/releases/latest | ConvertFrom-Json
    $asset = $rel.assets | Where-Object { $_.name -match 'release-msvc\.7z$' } | Select-Object -First 1
    Need $asset 'no mesa asset'
    Invoke-WebRequest $asset.browser_download_url -OutFile "$root\mesa.7z"
    7z x "$root\mesa.7z" "-o$root\mesa" -y | Out-Null
    Copy-Item "$root\mesa\x64\opengl32.dll", "$root\mesa\x64\libgallium_wgl.dll" $app
    if (Test-Path "$root\mesa\x64\libglapi.dll") { Copy-Item "$root\mesa\x64\libglapi.dll" $app }
}
$env:GALLIUM_DRIVER = 'llvmpipe'

# A live app: open panes and drive them like a script would.
$proc = Start-Process $exe -PassThru -RedirectStandardOutput "$out\app-out.txt" -RedirectStandardError "$out\app-err.txt"
Start-Sleep 8
function Ctl { $r = (& $exe --ctl @args 2>&1 | Out-String).Trim(); Write-Host "ctl $args -> [$LASTEXITCODE] $r"; $r }

Step 'app stays up' { Need (-not $proc.HasExited) "exited with $($proc.ExitCode)" }
Step 'ctl ls' { Ctl ls | Out-Null; Need ($LASTEXITCODE -eq 0) 'ls failed' }
Step 'default shell pane (PowerShell)' {
    $id = Ctl new island
    Need ($LASTEXITCODE -eq 0) 'new island failed'
    Ctl wait $id --prompt --timeout 60000 | Out-Null
    $waited = $LASTEXITCODE
    Start-Sleep 2
    (Ctl read $id) | Set-Content "$out\pane-shell-start.txt"
    (Ctl status $id --json) | Set-Content "$out\pane-shell-status.txt"
    Need ($waited -eq 0) 'no prompt mark (shell integration)'
    $got = Ctl run $id 'echo hi-from-ci' --timeout 30000
    $code = $LASTEXITCODE
    (Ctl read $id) | Set-Content "$out\pane-shell-run.txt"
    Need ($code -eq 0 -and $got -match 'hi-from-ci') "run gave [$code] $got"
    $cwd = Ctl ls
    Need ($cwd -match '[A-Za-z]:/|~') "no cwd in ls: $cwd"
}
Step 'cmd pane' {
    $id = Ctl new island '--' cmd.exe  # quoted: PowerShell eats a bare --
    Need ($LASTEXITCODE -eq 0) 'new island failed'
    Start-Sleep 3
    Ctl send $id 'echo cmd-says-%OS%' --enter | Out-Null
    Ctl wait $id --match 'cmd-says-Windows_NT' --timeout 20000 | Out-Null
    $code = $LASTEXITCODE
    (Ctl read $id) | Set-Content "$out\pane-cmd.txt"
    Need ($code -eq 0) 'cmd output never showed'
}
Step 'app still up' { Need (-not $proc.HasExited) "exited with $($proc.ExitCode)" }
if (-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }
Start-Sleep 1
Get-Content "$out\app-out.txt", "$out\app-err.txt" -ErrorAction SilentlyContinue

# A picture of a pane after its shell started (best effort: frames only tick when something happens).
Step 'screenshot' {
    $env:JZERO_ACTIONS = 'new_island'
    $env:J3_CAPTURE = "$out\shot.png:240"
    $shot = Start-Process $exe -PassThru -RedirectStandardOutput "$out\shot-out.txt" -RedirectStandardError "$out\shot-err.txt"
    if (-not $shot.WaitForExit(60000)) { Stop-Process -Id $shot.Id -Force }
    $env:JZERO_ACTIONS = $null; $env:J3_CAPTURE = $null
    Need (Test-Path "$out\shot.png") 'no screenshot written'
}

Write-Output "failed: $($script:failed -join ', ')"
exit $script:failed.Count
