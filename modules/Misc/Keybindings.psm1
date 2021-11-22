# Navigation
Set-PSReadLineKeyHandler -Chord "Ctrl+h" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd ~')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}