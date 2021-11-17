function Invoke-Prompt {
    $config = Get-Content $env:PWSH_CONFIG | ConvertFrom-Json
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