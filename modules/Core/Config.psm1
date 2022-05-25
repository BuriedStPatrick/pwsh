Import-Module (Join-Path $env:PWSH_REPO modules PSYaml PSYaml)

function Get-Config {
    $defaultConfigContent = (Get-Content (Join-Path $env:PWSH_REPO pwsh.yaml))
    $hasUserConfig = (Test-Path $env:PWSH_CONFIG) -eq $true

    $config = $hasUserConfig `
        ? (yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' (Join-Path $env:PWSH_REPO pwsh.yaml) $env:PWSH_CONFIG) `
        : $defaultConfigContent

    $config = $config | Format-EnvironmentVariables | Format-Paths

    $hash = Get-Random
    $tempConfigPath = (Join-Path $env:TMP "pwsh.$hash.yaml")

    $config | Where-Object { !($_ -ilike '*#*') -and $_ } | Out-File -Path $tempConfigPath
    $config = (ConvertFrom-Yaml -Path $tempConfigPath)

    Remove-Item $tempConfigPath

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

function Edit-Configs {
    # Paths to potential config files
    $configs = @(
        (Join-Path $env:APPDATA "alacritty" "alacritty.yml"),
        (Get-ChildItem (Join-Path $env:LOCALAPPDATA "Packages" "Microsoft.WindowsTerminal_*" "LocalState" "settings.json")).FullName),
        (Join-Path $env:HOME ".gitconfig"),
        (Join-Path $env:HOME ".config" "starship.toml")
        | Where-Object { Test-Path $_ }

    $config = Read-Option "Select config to edit" $configs

    if ($config) {
        "$env:EDITOR $config" | Invoke-Expression
    }
}

# Keybinds
Set-PSReadLineKeyHandler -Chord "Ctrl+." -Description "Edit pwsh.yaml config with $env:EDITOR" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Edit-UserConfig')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+e -Description "Pick a config file to edit with $env:EDITOR" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Edit-Configs')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
