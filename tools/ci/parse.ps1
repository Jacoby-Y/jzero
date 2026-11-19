# Fail when a shipped PowerShell script has a syntax error in this PowerShell.
$bad = 0
foreach ($f in $args) {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $f).Path, [ref]$null, [ref]$errs) | Out-Null
    foreach ($e in $errs) { Write-Output "$f`:$($e.Extent.StartLineNumber): $($e.Message)"; $bad = 1 }
}
Write-Output "parsed $($args.Count) scripts with PowerShell $($PSVersionTable.PSVersion), bad=$bad"
exit $bad
