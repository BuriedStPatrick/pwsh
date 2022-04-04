Import-Module (Join-Path $env:PWSH_REPO "modules" "Core" "Config.psm1")

<#
.SYNOPSIS
Get PWSH profile modules with status

.DESCRIPTION
Get PWSH profile modules with status

.EXAMPLE
Get-ProfileModules -Include Enabled,Disabled

.NOTES

#>
function Get-ProfileModules {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string[]]$Include
    )
    process {
        $config = Get-Config

        return $config.modules.Keys | ForEach-Object {
            $module = $null

            if ($Include?.Length -lt 1) {
                $module = $_
            }

            if ($config.modules["$($_)"]?.disabled -eq $true -and $Include?.Contains("Disabled")) {
                $module = $_
            }

            if ($config.modules["$($_)"]?.disabled -eq $false -and $Include?.Contains("Enabled")) {
                $module = $_
            }

            if ($null -ne $module) {
                return @{
                    Name = $_
                    Disabled = $config.modules["$($_)"]?.disabled
                }
            }
        } | Where-Object { !( $_ -eq $null )}
    }
}
