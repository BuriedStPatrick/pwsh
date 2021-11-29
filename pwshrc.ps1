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
    $env:PWSH_CONFIG = $env:PWSH_CONFIG ?? (Join-Path $pwshConfigDir pwsh.yaml)
    $env:EDITOR = $env:EDITOR ?? 'nvim'
}

function Invoke-InitScripts {
    # Load init scripts
    Get-ChildItem (Join-Path $env:PWSH_HOME init\*.ps1) -File `
        | Where-Object { !($_.Name.Replace(".ps1", "") -in $pwshConfig.init.disabled)} `
        | ForEach-Object { . $_.FullName }
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

# Load modules
Invoke-Modules

# Load init scripts
Invoke-InitScripts

# Start prompt
Invoke-Prompt