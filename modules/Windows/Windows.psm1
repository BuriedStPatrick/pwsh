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

    $minutes = [int]::Parse((Read-String "In how many minutes?"))

    $seconds = $minutes * 60
    $action = $action + " /t $($seconds)"

    $action | Invoke-Expression
}
