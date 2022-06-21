$env:PWSH_REPO = $env:PWSH_REPO ?? (Split-Path -Parent $MyInvocation.MyCommand.Definition)

function Invoke-EnvironmentVariables() {
    $env:PWSH_CONFIG_DIR = $IsWindows `
        ? (Join-Path $env:LOCALAPPDATA pwsh) `
        : (Join-Path $HOME .config pwsh)

    $env:PWSH_HOME = $env:PWSH_HOME ?? (Join-Path $HOME pwsh)
    $env:PWSH_CACHE = $env:PWSH_CACHE ?? (Join-Path $HOME .cache pwsh)
    $env:PWSH_CONFIG = $env:PWSH_CONFIG ?? (Join-Path $env:PWSH_CONFIG_DIR pwsh.yaml)
    $env:EDITOR = $env:EDITOR ?? 'nvim'
    $env:HOME = $env:HOME ?? $env:USERPROFILE
}

function Invoke-EnsureEssentialDirectories {
    @($env:PWSH_HOME, $env:PWSH_CACHE) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
}

function Invoke-Core {
    # Load the core modules
    Get-ChildItem (Join-Path $env:PWSH_REPO modules\Core\*.psm1) -File `
    | ForEach-Object { Import-Module $_.FullName }
}

function Invoke-Modules($config) {
    # Get disabled module names
    $modules = $config.modules
    $disabledModules = $modules.Keys | Where-Object { !$modules[$_].enabled }

    # Load enabled feature modules
    Get-ChildItem (Join-Path $env:PWSH_REPO modules) -Directory `
        | Where-Object { !($_.Name -eq "Core") -and  !($_.Name -in $disabledModules) } `
        | ForEach-Object { Get-ChildItem "$($_.FullName)\*.psm1" } `
        | ForEach-Object { Import-Module $_.FullName }
}

function Invoke-Path($config) {
    $path = $env:Path.Split(";") | Where-Object { $_ } | Sort-Object | Get-Unique
    $path += $config.paths.include
    $path = $path | Where-Object { !( $config.paths.exclude.Contains($_)) }

    $env:Path = [string]::Join(";", $path)
}

# Load environment variables
Invoke-EnvironmentVariables

# Ensure essential dirs exist
Invoke-EnsureEssentialDirectories

# Load core modules
Invoke-Core

# Get config
$config = Get-Config

# Load modules
Invoke-Modules $config

# Update PATH
Invoke-Path $config

# Start prompt
if ($config.modules?.Prompt?.enabled ?? $false) {
    Invoke-Prompt $config.modules?.Prompt?.config
}
