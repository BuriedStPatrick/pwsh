$path = (Join-Path $env:PWSH_REPO "modules" "Npm" "npm-completion" "src" "npm-completion.psd1")

if (!(Test-Path $path)) {
    Push-Location $env:PWSH_REPO

    try {
        git submodule init
        git submodule update
    } finally {
        Pop-Location
    }
}

Import-Module $path