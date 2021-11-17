# Navigation
Set-PSReadLineKeyHandler -Chord "Ctrl+h" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd ~')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Edit Config
Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"$env:EDITOR $env:PWSH_CONFIG" | Invoke-Expression') # TODO: Use $env:EDITOR
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}