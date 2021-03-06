Import-Module (Join-Path $env:PWSH_REPO modules PSYaml PSYaml)

function Get-Config {
    $defaultConfigContent = (Get-Content (Join-Path $env:PWSH_REPO pwsh.yaml))
    $hasUserConfig = (Test-Path $env:PWSH_CONFIG) -eq $true

    $config = $hasUserConfig `
        ? (yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' (Join-Path $env:PWSH_REPO pwsh.yaml) $env:PWSH_CONFIG) `
        : $defaultConfigContent

    $config = $config | Format-EnvironmentVariables | Format-Paths

    $config | Where-Object { !($_ -ilike '*#*') -and $_ } > $env:TMP\pwsh.yaml
    $config = (ConvertFrom-Yaml -Path $env:TMP\pwsh.yaml)

    Remove-Item $env:TMP\pwsh.yaml

    return $config
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