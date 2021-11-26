Set-PSReadLineKeyHandler -Chord Ctrl+p -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-FuzzyPasswordFolders | Set-Clipboard')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}