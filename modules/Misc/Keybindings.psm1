# Navigation
Set-PSReadLineKeyHandler -Chord "Ctrl+h" -Description "Navigate: Home" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd ~')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}