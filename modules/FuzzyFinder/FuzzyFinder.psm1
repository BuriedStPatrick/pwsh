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
        # If known text file type, open with configured editor
        $editor = Get-Editor -FilePath $selection
        if ($editor) {
            "$($editor.path) $selection" | Invoke-Expression
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

function Get-Editor($FilePath) {
    $extension = (Get-ChildItem (Convert-Path $FilePath)).Extension

    return (Get-Config).editors
        | Where-Object { $_.extensions.Contains($extension) }
        | Select-Object -First 1
}
