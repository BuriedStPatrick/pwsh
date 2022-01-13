function Read-Option($prompt, $options) {
    $selector = (Get-Config).modules.Prompt.config.selector
    $useFzf = (($selector -eq 'fzf') -and (Test-Command fzf))

    if (!$useFzf) {
        $options | ForEach-Object { $i = 0 } {
            Write-Host " [$i] $_"
            $i++
        }

        Write-Host "[0-$($options.Length - 1)]" -ForegroundColor Black -BackgroundColor Blue -NoNewline
        $selectedIndex = [int](Read-Host " $prompt")

        if ($selectedIndex -lt 0 -or ($selectedIndex -gt $options.Length - 1)) {
            throw "Invalid selection: $selectedIndex"
        }

        $selection = $options[$selectedIndex]
    } else {
        $selection = ($options | fzf --layout reverse --border --prompt "$prompt > ")
    }

    return $selection
}

function Read-String($prompt) {
    Write-Host "[?]" -ForegroundColor Black -BackgroundColor Blue -NoNewline
    return (Read-Host " $prompt")
}

function Read-OptionList($prompt, $options) {
    $selector = (Get-Config).modules.Prompt.config.selector
    $useFzf = (($selector -eq 'fzf') -and (Test-Command fzf))
    $selections = @()

    if (!$useFzf) {
        $options | ForEach-Object { $i = 0 } {
            Write-Host " [$i] $_"
            $i++
        }

        Write-Host "[0-$($options.Length - 1)]" -ForegroundColor Black -BackgroundColor Blue -NoNewline
        $selectedIndices = (Read-Host " $prompt (index, comma separated)").Split(',')

        $selectedIndices | ForEach-Object {
            $index = [int]$_
            if ($index -lt 0 -or ($index -gt $options.Length - 1)) {
                throw "Invalid selection: $index"
            }

            $selections += $options[$index]
        }
    } else {
        $selections = ($options | fzf --layout reverse --multi --border --header "Select/Deselect with Tab/Shift+Tab" --prompt "$prompt > ")
    }

    return $selections
}

function Read-Boolean($prompt) {
    Write-Host " Y/n " -ForegroundColor Black -BackgroundColor Blue -NoNewline
    $value = (Read-Host " $prompt") 

    return "" -eq $value -or $value.ToLower() -match '^y(es)?$'
}

function Write-Message($prefix, $prefixForeground, $prefixBackground, $message) {
    Write-Host $prefix -ForegroundColor $prefixForeground -BackgroundColor $prefixBackground -NoNewline
    Write-Host " " -NoNewline
    Write-Host $message
}

function Write-OkMessage($message) {
    Write-Message " OK " Black Green $message
}

function Write-InfoMessage($message) {
    Write-Message " INFO " Black Blue $message
}

function Write-WarningMessage($message) {
    Write-Message " WARN " Black Yellow $message
}

function Write-ErrorMessage($message) {
    Write-Message " ERR " Black Red $message
}

function Write-FatalMessage($message) {
    Write-Message " FATAL " Black Red $message
}