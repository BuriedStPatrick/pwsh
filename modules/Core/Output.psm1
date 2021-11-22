<#
    This module contains Core functionality used by other modules and should not be disabled.
#>
function Read-Boolean($prompt) {
    Write-Host "[Y/n]" -ForegroundColor Black -BackgroundColor Blue -NoNewline
    $value = (Read-Host " $prompt") 

    return "" -eq $value -or $value.ToLower() -match '^y(es)?$'
}

function Write-Message($prefix, $prefixForeground, $prefixBackground, $message) {
    Write-Host $prefix -ForegroundColor $prefixForeground -BackgroundColor $prefixBackground -NoNewline
    Write-Host " " -NoNewline
    Write-Host $message
}

function Write-OkMessage($message) {
    Write-Message "[OK]" Black Green $message
}

function Write-InfoMessage($message) {
    Write-Message "[INFO]" Black Blue $message
}

function Write-WarningMessage($message) {
    Write-Message "[WARN]" Black Yellow $message
}

function Write-ErrorMessage($message) {
    Write-Message "[ERR]" Black Red $message
}