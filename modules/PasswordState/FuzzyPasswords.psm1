function Invoke-FuzzyPasswordFolders {
    $folders = Get-PasswordFolders
    $selection = ($folders.TreePath | fzf --layout reverse)

    $sel = $folders | Where-Object { $_.TreePath -eq $selection }

    if (!$null -eq $sel.FolderID) {
        $passwordLists = Get-PasswordLists | Where-Object { $_.TreePath.StartsWith($sel.TreePath) }
        $selection = ($passwordLists.PasswordList | fzf --layout reverse)

        $sel = $passwordLists | Where-Object { $_.PasswordList -eq $selection }

        if (!$null -eq $sel.PasswordListID) {
            Invoke-FuzzyPasswords $sel.PasswordListID
        }
    }
}

function Invoke-FuzzyPasswordLists {
    $passwordLists = Get-PasswordLists
    $selection = ($passwordLists.PasswordList | fzf --layout reverse)

    $sel = $passwordLists | Where-Object { $_.PasswordList -eq $selection }

    if (!$null -eq $sel.PasswordListID) {
        Invoke-FuzzyPasswords $sel.PasswordListID
    }
}

function Invoke-FuzzyPasswords($listId) {
    $passwords = Get-Passwords $listId
    $selection = ($passwords.Title | fzf --layout reverse)

    $sel = $passwords | Where-Object { $_.Title -eq $selection }

    if (!$null -eq $sel) {
        return (Invoke-PasswordStateFetchPassword $sel.PasswordID).Password
    }
}