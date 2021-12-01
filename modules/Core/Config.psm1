Import-Module (Join-Path $env:PWSH_HOME modules PSYaml PSYaml)

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
    $cachedConfigPath = (Join-Path $env:PWSH_CACHE pwsh.yaml)
    $userConfigPath = (Join-Path $env:PWSH_HOME pwsh.yaml)

    if ((Test-Path $userConfigPath)) {
        if (!(Test-Command yq)) {
            Write-FatalMessage "yq is required"
            return
        }

        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' (Join-Path $env:PWSH_HOME .\pwsh.yaml) $env:PWSH_CONFIG > $cachedConfigPath
        $configPath = $cachedConfigPath
    } else {
        $configPath = (Join-Path $env:PWSH_HOME pwsh.yaml)
    }

    return ConvertTo-Object (ConvertFrom-Yaml -Path $configPath)
}

function Edit-UserConfig {
    if (!(Test-Path $env:PWSH_CONFIG)) {
        Write-WarningMessage "User config not found at '$env:PWSH_CONFIG'"
        if (!(Read-Boolean "Create?")) {
            Write-InfoMessage "Aborted"
            return
        }

        Copy-Item (Join-Path $env:PWSH_HOME pwsh.yaml) $env:PWSH_CONFIG -Force
    }

    "$env:EDITOR $env:PWSH_CONFIG" | Invoke-Expression
}

# Keybinds
Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Edit-UserConfig')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}