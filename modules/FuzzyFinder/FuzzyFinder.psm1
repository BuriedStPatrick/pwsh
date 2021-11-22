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
        Invoke-Item $selection
    }

    # If selection is a directory, navigate and invoke this function again
    if (Test-Path -Path $selection -PathType Container) {
        Set-Location $selection
        Invoke-FuzzyFile
    }
}