# Invokes fzf in the current directory.
# On selection:
#   if the selected item is a directory, cd's into it and re-invokes itself to allow further navigation.
#   if the selected item is a file, calls Invoke-Item on it.
function Invoke-FuzzyFile {
    $results += @("..") + (Get-ChildItem).Name

    $selection = $($results | fzf --layout reverse)

    if ($null -eq $selection -or "" -eq $selection) {
        return
    }

    # If selection is file, open it
    if (Test-Path -Path $selection -PathType Leaf) {
        # If known text file type, open with configured EDITOR
        if ((Test-IsTextFile -FilePath $selection)) {
            "$env:EDITOR $selection" | Invoke-Expression
        }
        # Otherwise, just open it with default app
        else {
            Invoke-Item $selection
        }
    }

    # If selection is a directory, navigate and invoke this function again
    if (Test-Path -Path $selection -PathType Container) {
        Set-Location $selection
        Invoke-FuzzyFile
    }
}

function Test-IsTextFile($FilePath) {
    $extension = (Get-ChildItem (Convert-Path $selection)).Extension

    return @(
        '.txt',
        '.md',
        '.yml',
        '.yaml',
        '.html',
        '.js',
        '.json',
        '.toml',
        '.xml',
        '.config',
        '.css',
        '.scss',
        '.less',
        '.cs',
        '.ps1',
        'psm1',
        '.sh',
        '.gitmodules',
        '.gitattributes',
        '.gitconfig').Contains($extension)
}
