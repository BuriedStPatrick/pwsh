function Test-IsAdministrator {
    if ($IsWindows) {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }

    throw "Cannot check admin status on non-Windows OS"
}