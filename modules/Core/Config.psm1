Import-Module (Join-Path $env:PWSH_HOME modules PSYaml PSYaml)

Function Join-Object {
    <#
    .description
        Copy and append BaseObject with new values from UpdateObject (Does not mutate BaseObject)
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [PSCustomObject]$BaseObject,

        [Parameter(Mandatory, Position = 1)]
        [PSCustomObject]$UpdateObject
    )

    if ($null -eq $BaseObject) {
        return $UpdateObject
    }

    $NewObject = $BaseObject.psobject.copy()
    $UpdateObject.psobject.properties | ForEach-Object {
        $PropName = $_.Name
        $Value = $_.Value

        if ($null -eq $NewObject.$PropName) {
            $NewObject | Add-Member -NotePropertyName $PropName -NotePropertyValue $Value
        } else {

            $NewObject.($PropName) = $Value
        }
    }

    $NewObject
}

function Get-Config {
    $defaultConfigPath = (Join-Path $env:PWSH_HOME pwsh.yaml)
    if (Test-Path($defaultConfigPath)) {
        $defaultConfig = ConvertFrom-Yaml = $defaultConfigPath
    }

    $userConfigPath = (Join-Path $env:PWSH_HOME pwsh.yaml)
    if (Test-Path($userConfigPath)) {
        $userConfig = ConvertFrom-Yaml = $userConfigPath
    }

    return ($null -eq $userConfig) ? (Join-Object $defaultConfig $userConfig) : $defaultConfig
}

# Keybinds
Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"$env:EDITOR $env:PWSH_CONFIG" | Invoke-Expression')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}