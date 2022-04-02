function Invoke-LoadArgParser {
    # Check that module was fetched via Git. If not, update submodules.
    if (!(Test-Path (Join-Path $env:PWSH_REPO "modules" "Cli" "ArgParser"))) {
        Push-Location $env:PWSH_REPO
        try {
            git submodule init
            git submodule update
        } finally {
            Pop-Location
        }
    }

    # Check that module was build. If not, run build
    if (!(Test-Path (Join-Path $env:PWSH_REPO "modules" "Cli" "ArgParser" "Output" "ArgParser" "ArgParser.psd1"))) {
        Push-Location (Join-Path $env:PWSH_REPO "modules" "Cli" "ArgParser")
        try {
            .\Install-Requirements.ps1
            .\Start-ModuleBuild.ps1
        } finally {
            Pop-Location
        }
    }

    # Import the module
    Import-Module (Join-Path $env:PWSH_REPO "modules" "Cli" "ArgParser" "Output" "ArgParser")
}

function Invoke-ProfileCli {
    # Load ArgParser module
    Invoke-LoadArgParser

    # Parse arguments into an array, assume arguments space delimited
    try {
        $arguments = $args.Split(' ')
    } catch {
        # Unable to parse arguments which probably means nothing was entered beyond the root command 'profile'
        # Print a user-friendly message, perhaps the help documentation
        Write-Host "Usage: profile <command> <flags>"
        return
    }

    # Hack: Force $arguments to be an array even if it's only a single entry.
    # PowerShell treats single entry arrays as strings otherwise.
    if (($arguments -is [string])) {
        $arguments = @($arguments)
    }

    # Print the version of the CLI if requested
    if (Get-ArgParserHasSwitch -Name "version" -ShortName "v" -Arguments $arguments) {
        Write-Host "Version: 1.0.0.0"
    }

    # Print helpful documentation of the CLI if requested, break out of application flow
    if (Get-ArgParserHasSwitch -Name "help" -ShortName "h" -Arguments $arguments) {
        Write-Help @args
        return
    }

    $name = Get-ArgParserStringValue -Name "name" -ShortName "n" -Arguments $arguments
    if ($name) {
       Write-Host "Hello, $name! You have been reported to the authorities, have a great day :D"
    }
}

Set-Alias profile Invoke-ProfileCli
Export-ModuleMember -Function Invoke-ProfileCli -Alias profile
