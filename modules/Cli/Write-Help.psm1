function Write-Help {
    $action = (Get-Content (Join-Path $env:PWSH_REPO "modules" "Cli" "actions.json") | ConvertFrom-Json)
    $args | Where-Object { !($_ -like '-*') } | ForEach-Object {
        $action = $action."$_"
    }

    $helpText = $action.helpText
    if(!($null -eq $helpText)) {
        Write-Output "Description:"
        Write-Output "`t$helpText"
    }

    $flags = $action.flags
    if(!($null -eq $flags) -and ($flags.Length -gt 0)) {
        Write-Output "Flags:"
        $flags.PSObject.Properties | ForEach-Object {
            $required = $_.Value.required -eq $true ? "[Required]" : ""

            $shortName = $_.Value.shortName ? ", -$($_.Value.shortName)" : $null
            Write-Output "`t--$($_.Name)$shortName [$($_.Value.type)] $required"

            if ($_.Value.helpText) {
                Write-Output "`t`t$($_.Value.helpText)"
            }

            if ($_.Value.default) {
                Write-Output "`t`tDefault: $($_.Value.default)"
            }
        }
    }

    $examples = $action.examples
    if(!($null -eq $examples) -and ($examples.Length -gt 0)) {
        Write-Output "Examples:"
        $examples | ForEach-Object {
            Write-Output "`t$_"
        }
    }

    $commands = $action.PSObject.Properties | Where-Object {
        !($_.Name -like 'helpText') -and !($_.Name -like 'examples') -and !($_.Name -like 'flags')
    }

    if ($commands.Length -gt 0) {
        Write-Output "Commands:"
        $commands | ForEach-Object {
            Write-Output "`t$($_.Name) - $($_.Value.helpText)"
        }
    }
}