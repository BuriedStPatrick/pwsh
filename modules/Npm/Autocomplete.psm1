$modulePath = (Join-Path $env:PWSH_REPO "modules" "Npm")

$modules = @(
    (Join-Path $modulePath "npm-completion" "src" "npm-completion.psd1"),
    (Join-Path $modulePath "yarn-completion" "src" "yarn-completion.psd1")
)

$missing = $modules | Where-Object { (!(Test-Path $_ )) }

if ($missing.Length -gt 0) {
    Push-Location $env:PWSH_REPO

    try {
        git submodule init
        git submodule update
    } finally {
        Pop-Location
    }
}

$modules | ForEach-Object {
    Import-Module $_
}
