# Replaces enviroment variables with their given values
function Format-EnvironmentVariables {
    [cmdletbinding()]
    param(
        [parameter(
            Mandatory                       = $false,
            ValueFromPipeline               = $true,
            ValueFromPipelineByPropertyName = $true
            )]
        [string]$content
    )
    process {
        $content | Select-String -Pattern '\$\{(.*?)\}' -AllMatches | ForEach-Object {
            $_.matches | ForEach-Object {
                $propertyName = $_.groups[1]
                $environmentVarValue = ((Get-Item -Path Env:* | Where-Object { $_.Name -eq $propertyName }) | Select-Object -First 1)?.Value

                $content = $content.Replace($_.groups[0], $environmentVarValue)
            }
        }

        return $content
    }
}

# Replaces config variables with their given values
function Format-ConfigValues {
    [cmdletbinding()]
    param(
        [parameter(
            Mandatory                       = $false,
            ValueFromPipeline               = $true,
            ValueFromPipelineByPropertyName = $true
            )]
        [string]$Content,
        [parameter(
            Mandatory = $true
        )]
        $Config
    )
    process {
        $Content | Select-String -Pattern '#\{(.*?)\}' -AllMatches | ForEach-Object {
            $_.matches | ForEach-Object {
                $propertyNames = $_.groups[1].Value.Split(".")

                $value = $Config
                $propertyNames | ForEach-Object {
                    $value = $value[$_]
                }

                $Content = $Content.Replace($_.groups[0], $value)
            }
        }

        return $Content
    }
}

# Ensures paths are correctly formatted
function Format-Paths {
    [cmdletbinding()]
    param(
        [parameter(
            Mandatory                       = $false,
            ValueFromPipeline               = $true,
            ValueFromPipelineByPropertyName = $true
            )]
        [string]$content
    )
    process {
        $content | Select-String -Pattern '[a-zA-Z]:[\\\/](?:[a-zA-Z0-9]+[\\\/])*([a-zA-Z0-9]+\.*)' -AllMatches | ForEach-Object {
            $_.matches | ForEach-Object {
                $value = (Test-Path $_.groups[0]) `
                    ? (Convert-Path $_.groups[0]) `
                    : $_.groups[0]

                $content = $content.Replace($_.groups[0], $value)
            }
        }

        return $content
    }
}
