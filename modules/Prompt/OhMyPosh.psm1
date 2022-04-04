function Get-OhMyPoshThemes {
    if (!(Test-Path $env:POSH_THEMES_PATH)) {
        Write-ErrorMessage "Couldn't find oh-my-posh themes. Path: $env:POSH_THEMES_PATH"
    }

    return Get-ChildItem (Join-Path $env:POSH_THEMES_PATH *.omp.json)
}

Export-ModuleMember -Function Get-OhMyPoshThemes