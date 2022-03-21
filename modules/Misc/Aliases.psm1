function Invoke-WhereIs {
    $ErrorActionPreference = "SilentlyContinue"
    $path = (Get-Command @args)?.Path

    if ($null -eq $path) {
        Write-WarningMessage "Not found: $($args)"
    }

    return $path
}

function Set-ParentLocation {
    Set-Location ".."
}

Set-Alias ".." Set-ParentLocation
Set-Alias whereis Invoke-WhereIs
Set-Alias open Invoke-Item
Set-Alias json ConvertTo-Json