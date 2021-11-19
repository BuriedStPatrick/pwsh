function Invoke-Prompt {
    $config = Get-Config
    switch($config.prompt) {
        "starship" {
            Invoke-Expression (&starship init powershell)
        }
        "omp" {
            Write-Host "Would invoke oh-my-posh..."
        }
    }
}

Invoke-Prompt
