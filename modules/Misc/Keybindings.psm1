# Navigation
Set-PSReadLineKeyHandler -Chord "Ctrl+h" -Description "History: Search and run" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cat (Get-PSReadLineOption).HistorySavePath | Select-Object -Unique | fzf --layout reverse | Invoke-Expression')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}