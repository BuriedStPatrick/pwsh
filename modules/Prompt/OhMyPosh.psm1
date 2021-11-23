function Get-OhMyPoshThemes {
    $themesPath = (Join-Path (Get-Command oh-my-posh).Source .. .. themes)

    if (!(Test-Path $themesPath)) {
        Write-ErrorMessage "Couldn't find oh-my-posh themes. Path: $themesPath"
    }

    return Get-ChildItem (Join-Path $themesPath *.omp.json)
}

function Write-OhMyPoshThemePreviews {
    Get-OhMyPoshThemes | ForEach-Object {
        $esc = [char]27
        Write-Host ""
        Write-Host "$esc[1m$($_.BaseName)$esc[0m"
        Write-Host ""
        oh-my-posh --config $($_.FullName) --pwd $PWD
        Write-Host ""
    }
}

Export-ModuleMember -Function Write-OhMyPoshThemePreviews
Export-ModuleMember -Function Get-OhMyPoshThemes