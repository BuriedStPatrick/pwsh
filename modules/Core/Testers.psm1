function Test-IsAdministrator {
    if ($IsWindows) {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }

    throw "Cannot check admin status on non-Windows OS"
}

function Test-Command($command) {
    $ErrorActionPreference = "SilentlyContinue"
    if (Get-Command $command) {
        return $true
    } else {
        return $false
    }
}

function Test-Module($module) {
    return !((Get-Config).modules?."$module"?.disabled ?? $true)
}