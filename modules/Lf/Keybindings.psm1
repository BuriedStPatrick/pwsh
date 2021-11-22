Set-PSReadLineKeyHandler -Chord Ctrl+o -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-Lfcd')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
