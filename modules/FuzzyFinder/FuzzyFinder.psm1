# FuzzyFinder helper functions to quickly get around!

function Invoke-FuzzyFile {
    $results += @("..") + (Get-ChildItem).Name

    $selection = $($results | fzf --layout reverse)

    if ($null -eq $selection -or "" -eq $selection) {
        return
    }

    if ($selection -eq "..") {
        Set-Location ..\
    }

    # If selection is file, open it
    if (Test-Path -Path $selection -PathType Leaf) {
        Invoke-Item $selection
    }

    # If selection is a directory, navigate and invoke this function again
    if (Test-Path -Path $selection -PathType Container) {
        Set-Location $selection
        Invoke-FuzzyFile
    }
}

# Key bindings
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-FuzzyFile')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord "Ctrl+``" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd ~')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}