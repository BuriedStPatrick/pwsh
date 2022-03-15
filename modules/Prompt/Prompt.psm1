function Invoke-Prompt {
    $config = (Get-Config).modules?.Prompt?.config
    switch($config.prompt) {
        "none" {
            return
        }
        "custom" {
            # Load the custom prompt script
            if (!$config.custom?.scriptPath) {
                Write-ErrorMessage "Missing scriptPath for custom script. Did you add it?"
                return
            }

            if ((Test-Path $config.custom.scriptPath)) {
                Write-WarningMessage "Custom prompt doesn't seem to work yet for some reason. Suggest adding it manually to $PROFILE"
                . $config.custom.scriptPath
            } else {
                Write-ErrorMessage "Couldn't find custom prompt script at '$($config.custom.scriptPath)'. You sure this is right?"
            }
        }
        "starship" {
            if (Test-Command starship) {
                Invoke-Expression (&starship init powershell)
            } else {
                Write-ErrorMessage "Starship prompt not installed or not configured in PATH"
            }
        }
        "omp" {
            if (Test-Command oh-my-posh) {
                $themes = Get-OhMyPoshThemes

                if ($config.omp?.theme) {
                    $theme = $themes | Where-Object { $_.Name -eq "$($config.omp.theme).omp.json" } | Select-Object -First 1
                }

                if ($theme) {
                    oh-my-posh --init --shell pwsh --config $theme.FullName | Invoke-Expression
                } else {
                    Write-ErrorMessage "Couldn't find oh-my-posh theme: '$($theme.Name)'"
                }
            } else {
                Write-ErrorMessage "Oh-My-Posh prompt not installed or not configured in PATH"
            }
        }
        default {
            Write-WarningMessage "Unknown prompt type '$($config.prompt)'. Falling back to 'none'"
            return
        }
    }

    if ($config.folderIcons) {
        if (!(Get-Module -ListAvailable -Name Terminal-Icons)) {
            Write-InfoMessage "Missing Terminal-Icons module. Installing."
            Install-Module -Name Terminal-Icons -Repository PSGallery
        }

        Import-Module -Name Terminal-Icons
    }

    if ($config.predictionMode -eq "history") {
        Set-PSReadLineOption -PredictionSource History
    }
}