$thisDirectory = (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$startBlock = "# < PWSH "
$endBlock   = "# > PWSH "

function New-PowershellProfile {
    $unixPath = Join-Path $HOME .config powershell
    if (!$IsWindows -and !(Test-Path($unixPath))) {
        New-Item $unixPath -ItemType Directory -Force
    }

    Write-Host "Profile-file missing. Adding '$PROFILE'"
    New-Item $PROFILE -ItemType File
}

function Install-Pwsh {
    if (!(Test-Path $PROFILE)) {
        New-PowershellProfile
    }

    $pwshrc = Get-Item (Convert-Path (Join-Path $thisDirectory "pwshrc")).Replace("\", "/")
    $pwshHomePath = Join-Path $HOME "pwsh"

    if (!(Test-Path $pwshHomePath)) {
        New-Item $pwshHomePath -ItemType Directory -Force
    }

    $pwshrcDestination = $IsWindows `
        ? (Join-Path $pwshHomePath "$($pwshrc.Name).ps1")
        : (Join-Path $pwshHomePath $pwshrc)

    # Copy pwshrc
    Copy-Item -Force $pwshrc.FullName $pwshrcDestination

    # Copy init-scripts
    Copy-Item -Recurse -Force (Join-Path $thisDirectory init) $pwshHomePath

    # Copy modules
    Copy-Item -Recurse -Force (Join-Path $thisDirectory modules) $pwshHomePath

    # Copy default pwsh.json
    Copy-Item -Force (Join-Path $thisDirectory pwsh.json) $pwshHomePath

    # Source pwshrc in profile automatically?
    $profileText = Get-Content $PROFILE -Raw -Encoding utf8
    if (!($profileText.Contains($startBlock) -and $profileText.Contains($endBlock))) {
        $sourceProfile = Read-Host "Source in profile? [Y/n]"
        if (! 'n' -eq $sourceProfile.ToLower()) {
            $profileText = Get-Content $PROFILE
    
            if (!($null -eq $profileText) -and $profileText.Contains($startBlock)) {
                return
            }

            $profileText = "`n$startBlock`n. $pwshrcDestination`n$endBlock`n"

            Add-Content $PROFILE $profileText -Encoding utf8 -NoNewLine
            Write-Host "Sourced file in profile: $pwshrcDestination"
        }
    }
}

function Install-DefaultConfig {
    # Add default config?
    $pwshConfigDir = $IsWindows `
        ? (Join-Path $env:LOCALAPPDATA pwsh)
        : (Join-Path $HOME .config pwsh)

    if (!(Test-Path $pwshConfigDir)) {
        New-Item $pwshConfigDir -Force -ItemType Directory
    }

    if (!(Test-Path(Join-Path $pwshConfigDir pwsh.json))) {
        # Copy default pwsh.json
        Copy-Item (Join-Path $thisDirectory pwsh.json) $pwshConfigDir
        Write-Host "Added config to $pwshConfigDir"
    }
}

function Uninstall-Pwsh {
    $pwshHomeDir = (Join-Path $HOME pwsh)

    if (Test-Path $pwshHomeDir) {
        Remove-Item -Recurse (Join-Path $HOME pwsh)
    }

    $profileText = Get-Content $PROFILE -Raw -Encoding utf8

    # Un-source pwshrc in the profile?
    if ($profileText.Contains($startBlock) -and $profileText.Contains($endBlock)) {
        $sourceProfile = Read-Host "Un-source in profile? [Y/n]"
        if (! 'n' -eq $sourceProfile.ToLower()) {
            $startIndex = $profileText.IndexOf($startBlock)
            $endIndex = $profileText.IndexOf($endBlock) + $endBlock.Length
            $len = $endIndex - $startIndex
            $profileText = $profileText.Replace($profileText.Substring($startIndex, $len), "")
            Set-Content $PROFILE $profileText -Encoding utf8 -NoNewLine
        }
    }

    $pwshConfigDir = $IsWindows `
        ? (Join-Path $env:LOCALAPPDATA pwsh)
        : (Join-Path $HOME .config pwsh)

    if (Test-Path(Join-Path $pwshConfigDir .\pwsh.json)) {
        $keepConfig = Read-Host "Keep config? [Y/n]"

        if ('n' -eq $keepConfig.ToLower()) {
            Remove-Item -Recurse $pwshConfigDir
        }
    }
}

$option = Read-Host "Pick an option`n(1) Install`n(2) Uninstall`n(3) Install default config`n"

function Write-Success($msg) {
    Write-Host "[OK] " -NoNewline -ForegroundColor Green
    Write-Host $msg
}

function Write-ErrorMessage($msg) {
    Write-Host "[ERROR] " -NoNewline -ForegroundColor Red
    Write-Host $msg
}

switch($option) {
    "1" {
        Install-Pwsh
        Write-Success "Installed"
    }
    "2" {
        Uninstall-Pwsh
        Write-Success "Uninstalled"
    }
    "3" {
        Install-DefaultConfig
        Write-Success "Installed default config"
    }
    default {
        Write-ErrorMessage "Invalid option"
    }
}

