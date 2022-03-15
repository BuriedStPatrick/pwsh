Set-PSReadLineKeyHandler -Chord Ctrl+p -Description "PasswordState: Search passwords, copy on selection" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-FuzzyPasswordFolders | Set-Clipboard')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}