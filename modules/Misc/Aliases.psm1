function Invoke-WhereIs {
    $ErrorActionPreference = "SilentlyContinue"
    return (Get-Command @args)?.Path
}

Set-Alias whereis Invoke-WhereIs
Set-Alias open Invoke-Item
