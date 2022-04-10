function Invoke-AutoHotkeyKeybindings($config) {
    Get-ChildItem (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "*.ahk.TEMPLATE") | ForEach-Object {
        $destination = $_.FullName.Replace(".TEMPLATE", "")
        if (!(Test-Path $destination)) {
            Get-Content $_.FullName | Format-EnvironmentVariables | Format-ConfigValues -Config (Get-Config) | Out-File $destination
        }
    }

    if ($config.loadKeybindsOnStartup -and !(Test-Path (Join-Path $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup" "Keybinds.ahk"))) {
        Install-AutoHotkeyKeybindings
    }
}

function Install-AutoHotkeyKeybindings {
    $startupDir = (Join-Path $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup")

    if (!(Test-IsAdministrator)) {
        Write-ErrorMessage "Unable to install AutoHotkey keybinds. Please run your as administrator to install."
        return
    }

    # Create symbolic links in startup directory
    Get-ChildItem -Exclude *.TEMPLATE (Join-Path $env:PWSH_REPO "modules" "AutoHotkey" "*.ahk") | ForEach-Object {
        $destination = (Join-Path $startupDir $_.Name)
        if (!(Test-Path $destination)) {
            Write-InfoMessage "Installing $($_.Name)"

            New-Item -ItemType SymbolicLink `
                -Path $destination `
                -Value $_.FullName
        }
    }
}

function Uninstall-AutoHotkeyKeybindings {
    if (!(Test-IsAdministrator)) {
        Write-ErrorMessage "Unable to uninstall AutoHotkey keybinds. Please run this command in an administrator context."
        return
    }

    $destination = (Join-Path $env:APPDATA "Microsoft" "Windows" "Start Menu" "Programs" "Startup" "Keybinds.ahk")
    if (!(Test-Path $destination)) {
        Write-ErrorMessage "Unable to uninstall AutoHotkey keybinds. The symbolic link does not exist."
        return
    }

    Remove-Item $destination
}

$config = (Get-Config).modules.AutoHotkey

if ($config.enabled -and !($null -eq $config.config)) {
    Invoke-AutoHotkeyKeybindings $config.config
}
