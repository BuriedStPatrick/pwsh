function Get-HasContent {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$content,
        [parameter(Mandatory= $true, ValueFromPipeline = $false)]
        [string]$match
    )
    process {
        return ($content -split "`r`n`r`n").replace("`r`n", "" ).Contains("$match")
    }
}


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

        return $content.Replace("\","/")
    }
}