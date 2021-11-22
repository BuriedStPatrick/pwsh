$config = (Get-Config).modules.PasswordState.config

function Get-PwmPassword($Id) {
    $passwordUrl = "$($config.baseUrl)/winapi/passwords"

    if (!($env:UserDomain -eq $config.domain)) {
        $Credentials = Get-PwmCredential
    } else {
        $Credentials = $null
    }

    try {
        if ($null -eq $Credentials) {
            return Invoke-Restmethod -Method GET -Uri "$passwordUrl/$Id" -UseDefaultCredentials
        } else {
            return Invoke-Restmethod -Method GET -Uri "$passwordUrl/$Id" -Credential $Credentials
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if (($statusCode -eq 401) -or ($statusCode -eq 403)) {
            Write-Error "You are not authorized to view this password ($Id)."
        } else {
            Write-Error "Failed to fetch password $($Id): $($_.Exception.Message)"
            throw $_
        }
    }
}

function Get-PasswordLists {
    $passwordListUrl = "$($config.baseUrl)/winapi/passwordlists"

    if (!($env:UserDomain -eq $config.domain)) {
        $Credentials = Get-PwmCredential
    } else {
        $Credentials = $null
    }

    try {
        if ($null -eq $Credentials) {
            return Invoke-Restmethod -Method GET -Uri "$passwordListUrl" -UseDefaultCredentials
        } else {
            return Invoke-Restmethod -Method GET -Uri "$passwordlistUrl" -Credential $Credentials
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if (($statusCode -eq 401) -or ($statusCode -eq 403)) {
            Write-Error "You are not authorized to view password lists."
        } else {
            Write-Error "Failed to fetch password lists: $($_.Exception.Message)"
            throw $_
        }
    }
}

function Get-Passwords($listId) {
    $listUrl = "$($config.baseUrl)/winapi/passwords/$($listId)?QueryAll"

    if (!($env:UserDomain -eq $config.domain)) {
        $Credentials = Get-PwmCredential
    } else {
        $Credentials = $null
    }

    try {
        if ($null -eq $Credentials) {
            return Invoke-Restmethod -Method GET -Uri $listUrl -UseDefaultCredentials
        } else {
            return Invoke-Restmethod -Method GET -Uri $listUrl -Credential $Credentials
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if (($statusCode -eq 401) -or ($statusCode -eq 403)) {
            Write-Error "You are not authorized to view passwords in list ($listId)."
        } else {
            Write-Error "Failed to fetch password $($Id): $($_.Exception.Message)"
            throw $_
        }
    }
}

function Get-PwmCredential {
    if (!(Test-Path Variable::global:PwmCred)-or($global:PwmCred-isnot[pscredential])) {
        Write-Host "🔐 PasswordState Credentials 🔐"
        $global:PwmCred = Get-Credential -Message "Please provide $($config.domain) domain account credentials"
    }

    return $global:PwmCred
}

function Clear-PwmCredential {
    $global:PwmCred = $null
}

function Format-PwmFile {
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $InputFile,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]
        $OutputFile,

        [Parameter(Mandatory = $false)]
        [switch]
        $VerboseOutput
    )
    process {
        if ([string]::IsNullOrEmpty($OutputFile)) {
            $OutputFile = $InputFile
        }

        if ($VerboseOutput) {
            Write-Host "[PasswordState]: $($OutputFile)..."
        }

        try {
            $Content = Get-Content $InputFile
            $Content |
                Select-String -Pattern '#\{PWM.(.*?)\((.*?)\)\}' -AllMatches |
                ForEach-Object {
                    $_.matches | ForEach-Object {
                        $PasswordId = $_.groups[2]
                        $Property = $_.groups[1]

                        $Password = Get-PwmPassword -PasswordId $PasswordId

                        $Content = $Content.Replace($_.groups[0], $Password."$Property")
                    }
                }

            Set-Content $OutputFile $Content
        } catch {
            Write-Error $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function * -Alias * -Variable *