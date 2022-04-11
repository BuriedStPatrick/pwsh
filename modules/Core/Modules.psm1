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

            if ($config.modules["$($_)"]?.enabled -eq $false -and $Include?.Contains("Disabled")) {
                $module = $_
            }

            if ($config.modules["$($_)"]?.enabled -eq $true -and $Include?.Contains("Enabled")) {
                $module = $_
            }

            if ($null -ne $module) {
                return @{
                    Name = $_
                    Enabled = $config.modules["$($_)"]?.enabled
                }
            }
        } | Where-Object { !( $_ -eq $null )}
    }
}
