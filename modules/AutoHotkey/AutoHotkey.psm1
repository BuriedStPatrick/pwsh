function Invoke-Keybindings($config) {
    Invoke-Item (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "Keybinds.ahk")

    $startupDir = (Join-Path $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup")

    if ($config?.loadKeybindsOnStartup -and !(Test-Path (Join-Path $startupDir "Keybinds.ahk"))) {
        if (!(Test-IsAdministrator)) {
            Write-WarnMessage "Unable to add AutoHotkey keybinds to Startup. Please run your profile as administrator to initially set this up."
            return
        }

        # Create symbolic link in startup directory
        Write-InfoMessage "Adding symbolic link for Keybinds.ahk to startup directory"

        New-Item -ItemType SymbolicLink `
            -Path (Join-Path $startupDir "Keybinds.ahk") `
            -Value (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "Keybinds.ahk")
    }
}

Invoke-Keybindings (Get-Config).modules.AutoHotkey?.config
