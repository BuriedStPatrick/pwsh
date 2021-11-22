Set-PSReadLineKeyHandler -Chord Ctrl+p -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-FuzzyPasswordLists | Set-Clipboard')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}