function Invoke-WhereIs {
    $ErrorActionPreference = "SilentlyContinue"
    $path = (Get-Command @args)?.Path

    if ($null -eq $path) {
        Write-WarningMessage "Not found: $($args)"
    }

    return $path
}

Set-Alias whereis Invoke-WhereIs
Set-Alias open Invoke-Item
Set-Alias json ConvertTo-Json