function Invoke-EnvironmentVariables() {
    $pwshConfigDir = $IsWindows `
        ? (Join-Path $env:LOCALAPPDATA pwsh) `
        : (Join-Path $HOME .config pwsh)

    $envOverrideFile = $IsWindows `
        ? (Join-Path $pwshConfigDir pwshenv.ps1) `
        : (Join-Path $pwshConfigDir pwshenv)

    if (Test-Path $envOverrideFile) {
        . $envOverrideFile
    }

    $env:PWSH_HOME = $env:PWSH_HOME ?? (Join-Path $HOME pwsh)
    $env:PWSH_CACHE = $env:PWSH_CACHE ?? (Join-Path $HOME .cache pwsh)
    $env:PWSH_CONFIG = $env:PWSH_CONFIG ?? (Join-Path $pwshConfigDir pwsh.yaml)
    $env:EDITOR = $env:EDITOR ?? 'nvim'
}

function Invoke-EnsureEssentialDirectories {
    @($env:PWSH_HOME, $env:PWSH_CACHE) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
}

function Invoke-Modules {
    # Load the core module
    Get-ChildItem (Join-Path $env:PWSH_HOME modules\Core\*.psm1) -File `
        | ForEach-Object { Import-Module $_.FullName }

    $pwshConfig = Get-Config

    # Get disabled module names
    $disabledModules = $pwshConfig.modules.PSObject.Properties `
        | Where-Object { $_.Value.disabled } `
        | Select-Object -ExpandProperty Name

    # Load enabled feature modules
    Get-ChildItem (Join-Path $env:PWSH_HOME modules) -Directory `
        | Where-Object { !($_.Name -eq "Core") -and  !($_.Name -in $disabledModules) } `
        | ForEach-Object { Get-ChildItem "$($_.FullName)\*.psm1" } `
        | ForEach-Object { Import-Module $_.FullName }
}

# Load environment variables
Invoke-EnvironmentVariables

# Ensure essential dirs exist
Invoke-EnsureEssentialDirectories

# Load modules
Invoke-Modules

# Start prompt
Invoke-Prompt