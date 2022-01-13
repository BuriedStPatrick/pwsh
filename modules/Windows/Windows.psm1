function Invoke-Shutdown {
    switch((Read-Option "Select option" @('shutdown', 'reboot'))) {
        'shutdown' {
            $action = 'shutdown /s'
        }
        'reboot' {
            $action = 'shutdown /r'
        }
    }

    if (!$action) {
        Write-InfoMessage "Abandoned shutdown"
        return
    }

    $when = (Read-String "In how many seconds?") ?? 0
    $action = $action + " /t $($when)"

    $action | Invoke-Expression
}
