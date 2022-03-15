Set-PSReadLineKeyHandler -Chord Ctrl+o -Description "LF: Run lf in current dir, navigate to selection on exit" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-Lfcd')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
