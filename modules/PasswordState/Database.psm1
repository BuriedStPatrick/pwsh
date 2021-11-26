<#
    This module manages the relationship of folders, password lists and passwords in a local database-file.
    It doesn't store actual passwords, only IDs and names of the folders, lists and passwords.
    The reason we need this is to avoid making unnecessary calls to the PasswordState password API, since it outputs the clear-text passwords even when you request the list view.
    For... some... reason... 🤦‍♂️
#>

# Ensure PasswordState home directory has been created
function Invoke-EnsurePasswordStateHomeDir {
    if (!(Test-Path $env:PWSH_PASSWORDSTATE_HOME)) {
        New-Item $env:PWSH_PASSWORDSTATE_HOME -ItemType Directory -Force
    }
}

# Update password lists database
function Update-PasswordLists($lists) {
    Invoke-EnsurePasswordStateHomeDir

    $lists | Select-Object -Property PasswordListID,PasswordList,TreePath | ConvertTo-Json > (Join-Path $env:PWSH_PASSWORDSTATE_HOME lists.json)
}

function Update-PasswordFolders($folders) {
    Invoke-EnsurePasswordStateHomeDir

    $folders | Select-Object -Property FolderID,TreePath | ConvertTo-Json > (Join-Path $env:PWSH_PASSWORDSTATE_HOME folders.json)
}

# Update passwords database
function Update-Passwords($listId, $passwords) {
    Invoke-EnsurePasswordStateHomeDir

    $passwords | Select-Object -Property PasswordID,Title | ConvertTo-Json > (Join-Path $env:PWSH_PASSWORDSTATE_HOME "$listId.json")
}

# Update all passwords in database
function Invoke-UpdateDatabase {
    Write-InfoMessage "Updating passwords database..."

    $lists = Invoke-PasswordStateFetchPasswordLists

    if (!$lists) {
        Write-ErrorMessage "Failed to update database: Couldn't fetch any password lists"
        return
    }

    Clear-Database

    Update-PasswordLists $lists

    $lists | ForEach-Object {
        Update-Passwords (Invoke-PasswordStateFetchPasswords $_.PasswordListID)
    }
}

function Get-PasswordLists {
    $path = (Join-Path $env:PWSH_PASSWORDSTATE_HOME lists.json)

    if (!(Test-Path $path)) {
        $lists = Invoke-PasswordStateFetchPasswordLists

        Update-PasswordLists $lists
    }

    return Get-Content $path | ConvertFrom-Json
}

function Get-PasswordFolders {
    $path = (Join-Path $env:PWSH_PASSWORDSTATE_HOME folders.json)

    if (!(Test-Path $path)) {
        $folders = Invoke-PasswordStateFetchFolders

        Update-PasswordFolders $folders
    }

    return Get-Content $path | ConvertFrom-Json
}

function Get-Passwords($listId) {
    $path = (Join-Path $env:PWSH_PASSWORDSTATE_HOME "$listId.json")

    if (!(Test-Path $path)) {
        $passwords = Invoke-PasswordStateFetchPasswords $listId

        Update-Passwords $listId $passwords
    }

    return Get-Content $path | ConvertFrom-Json
}

# Clear the database of passwords
function Clear-Database {
    Get-ChildItem (Join-Path $env:PWSH_PASSWORDSTATE_HOME "*.json") | Remove-Item
}

Export-ModuleMember -Function Update-PasswordLists
Export-ModuleMember -Function Update-Passwords
Export-ModuleMember -Function Update-Folders
Export-ModuleMember -Function Invoke-UpdateDatabase
Export-ModuleMember -Function Get-PasswordLists
Export-ModuleMember -Function Get-PasswordFolders
Export-ModuleMember -Function Get-Passwords
Export-ModuleMember -Function Clear-Database