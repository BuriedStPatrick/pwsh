function ConvertTo-Object($dictionary) {
    $dictionary | ForEach-Object {
        $props = @{}
        $_.GetEnumerator() | ForEach-Object {
            $props[$_.Key] = $_.Value
        }

        $props | Where-Object { $_.GetType() -eq "OrderedDictionary" } | ForEach-Object {
            write-host $_
        }

        return [PSCustomObject]$props
    }
}

function Get-Config {
    Import-Module (Join-Path $env:PWSH_REPO modules PSYaml PSYaml)

    $cachedConfigPath = (Join-Path $env:PWSH_CACHE pwsh.yaml)
    $userConfigPath = (Join-Path $env:PWSH_HOME pwsh.yaml)

    if ((Test-Path $userConfigPath)) {
        if (!(Test-Command yq)) {
            Write-FatalMessage "yq is required"
            return
        }

        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' (Join-Path $env:PWSH_HOME .\pwsh.yaml) $env:PWSH_CONFIG | Format-EnvironmentVariables > $cachedConfigPath
        $configPath = $cachedConfigPath
    } else {
        $configPath = (Join-Path $env:PWSH_HOME pwsh.yaml)
    }

    $obj = ConvertTo-Object (ConvertFrom-Yaml -Path $configPath)
    Remove-Module PSYaml

    return $obj
}

function Edit-UserConfig {
    if (!(Test-Path $env:PWSH_CONFIG)) {
        Write-WarningMessage "User config not found at '$env:PWSH_CONFIG'"
        if (!(Read-Boolean "Create?")) {
            Write-InfoMessage "Aborted"
            return
        }

        New-Item -ItemType Directory -Path $env:PWSH_CONFIG_DIR -Force

        Copy-Item -Path (Join-Path $env:PWSH_REPO pwsh.yaml) `
            -Destination $env:PWSH_CONFIG -Force
    }

    "$env:EDITOR $env:PWSH_CONFIG" | Invoke-Expression
}

# Keybinds
Set-PSReadLineKeyHandler -Chord Ctrl+. -Description "Edit pwsh.yaml config with $env:EDITOR" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Edit-UserConfig')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}