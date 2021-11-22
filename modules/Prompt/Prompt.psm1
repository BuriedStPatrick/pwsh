function Invoke-Prompt {
    $config = (Get-Config).modules?.Prompt?.config
    switch($config.prompt) {
        "none" {
            return
        }
        "custom" {
            # Load the custom prompt script
            if (Test-Path $config.customPromptScript) {
                . $config.customPromptScript
            } else {
                Write-ErrorMessage "Couldn't find custom prompt script at '$($config.customPromptScript)'. You sure this is right?"
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
                # Invoke-Expression (&oh-my-posh init powershell)
                Write-ErrorMessage "oh-my-posh not supported yet"
            } else {
                Write-ErrorMessage "Oh-My-Posh prompt not installed or not configured in PATH"
            }
        }
        default {
            Write-WarningMessage "Unknown prompt type '$($config.prompt)'. Falling back to 'none'"
            return
        }
    }
}