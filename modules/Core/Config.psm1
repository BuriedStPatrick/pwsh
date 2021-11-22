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
    $defaultConfigText = (Test-Path (Join-Path $env:PWSH_HOME pwsh.jsonc)) `
        ? (Get-Content (Join-Path $env:PWSH_HOME pwsh.jsonc))
        : $null

    if (!($null -eq $defaultConfigText)) {
        $defaultConfig = $defaultConfigText | ConvertFrom-Json
    }

    $userConfigText = (Test-Path $env:PWSH_CONFIG) `
        ? (Get-Content $env:PWSH_CONFIG)
        : $null

    if (!($null -eq $userConfigText)) {
        $userConfig = $userConfigText | ConvertFrom-Json
    }

    if (!($null -eq $userConfig)) {
        return Join-Object $defaultConfig $userConfig
    } else {
        return $defaultConfig
    }
}

# Keybinds
Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('"$env:EDITOR $env:PWSH_CONFIG" | Invoke-Expression')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}