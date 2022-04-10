function Invoke-AutoHotkeyKeybindings($config) {
    Get-ChildItem (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "*.ahk.TEMPLATE") | ForEach-Object {
        $destination = $_.FullName.Replace(".TEMPLATE", "")
        if (!(Test-Path $destination)) {
            Get-Content $_.FullName | Format-EnvironmentVariables | Format-ConfigValues -Config (Get-Config) | Out-File $destination
        }
    }

    if ($config?.loadKeybindsOnStartup -and !(Test-Path (Join-Path $startupDir "Keybinds.ahk"))) {
        Install-AutoHotkeyKeybindings
    }
}

function Install-AutoHotkeyKeybindings {
    $startupDir = (Join-Path $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup")

    if (!(Test-IsAdministrator)) {
        Write-ErrorMessage "Unable to install AutoHotkey keybinds. Please run your profile as administrator to initially set this up."
        return
    }

    # Create symbolic link in startup directory
    Write-InfoMessage "Adding symbolic link for Keybinds.ahk to startup directory"

    New-Item -ItemType SymbolicLink `
        -Path (Join-Path $startupDir "Keybinds.ahk") `
        -Value (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "Keybinds.ahk")
}

function Uninstall-AutoHotkeyKeybindsings {
    if (!(Test-IsAdministrator)) {
        Write-ErrorMessage "Unable to uninstall AutoHotkey keybinds. Please run this command in an administrator context."
        return
    }

    $destination = (Join-Path $startupDir $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup" "Keybinds.ahk")
    if (!(Test-Path $destination)) {
        Write-ErrorMessage "Unable to uninstall AutoHotkey keybinds. The symbolic link does not exist."
        return
    }

    Remove-Item $destination
}

$config = (Get-Config).modules.AutoHotkey

if ($config.enabled) {
    Invoke-AutoHotkeyKeybindings $config?.config
}
