function Invoke-EnvironmentVariables() {
    $pwshConfigDir = $IsWindows `
        ? (Join-Path $env:LOCALAPPDATA pwsh)
        : (Join-Path $HOME .config pwsh)

    $envOverrideFile = $IsWindows `
        ? (Join-Path $pwshConfigDir pwshenv.ps1)
        : (Join-Path $pwshConfigDir pwshenv)

    if (Test-Path $envOverrideFile) {
        . $envOverrideFile
    }

    $env:PWSH_HOME = $env:PWSH_HOME ?? (Join-Path $HOME pwsh)
    $env:PWSH_CONFIG = $env:PWSH_CONFIG ?? (Join-Path $pwshConfigDir pwsh.json)
    $env:EDITOR = $env:EDITOR ?? 'nvim'
}

Invoke-EnvironmentVariables