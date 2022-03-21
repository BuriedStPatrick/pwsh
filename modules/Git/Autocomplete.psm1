$modulePath = (Join-Path $env:PWSH_REPO "modules" "Git")

$modules = @(
    (Join-Path $modulePath "posh-git" "src" "posh-git.psd1")
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