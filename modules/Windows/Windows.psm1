function Invoke-Shutdown {
    switch((Read-Option "Select option" @('shutdown', 'reboot', 'abort'))) {
        'shutdown' {
            $action = 'shutdown /s'
        }
        'reboot' {
            $action = 'shutdown /r'
        }
        'abort' {
            $action = 'shutdown /a'
        }
    }

    if (!$action) {
        Write-InfoMessage "Abandoned shutdown"
        return
    }

    $when = ((Read-String "In how many minutes?") ?? 0) * 60
    $action = $action + " /t $($when)"

    $action | Invoke-Expression
}
