Set-PSReadLineKeyHandler -Chord Ctrl+f -Description "FuzzyFinder: Find file or directory with fuzzy search. Open with Enter." -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-FuzzyFile')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}