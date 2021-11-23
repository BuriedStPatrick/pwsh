$versions = @{
    "9.6.24" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257907"
    "10.9" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257881"
    "11.14" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257922"
    "12.9" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257917"
    "13.4" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257790"
    "14.1" = "https://sbp.enterprisedb.com/getfile.jsp?fileid=1257910"
}

function Install-PostgresClient($version) {
    if(!$IsWindows) {
        Write-ErrorMessage "Not supported on non-Windows unfortunately :("
        return -1
    }

    if (!$version) {
        @('fzf') | ForEach-Object {
            if (!(Test-Command $_)) {
                Write-ErrorMessage "$_ not found in PATH, cannot suggest versions`nTry running this with a -version parameter. Like:`n`nInstall-PostgresClient -version `"13.4`""
                return -1
            }
        }

        Write-InfoMessage "Select version to install"
        $version = ($versions.Keys | fzf --layout reverse --height 40%)
    }

    $url = $versions."$version"
    Write-InfoMessage "Downloading $url"

    Invoke-WebRequest $url -OutFile ~/Downloads/pgsql_binaries.zip
    Expand-Archive ~/Downloads/pgsql_binaries.zip -DestinationPath $env:TMP/pgsql_binaries

    $installDir = Read-Host "Install location"

    if (!(Test-Path($installDir))) {
        if((Read-Host "Location not found. Create? [y/N]").ToLower() -eq "y") {
            New-Item -ItemType Directory $installDir -Force | Out-Null
        } else {
            Write-ErrorMessage "Aborted install"
            return -1
        }
    }

    $installDir = Convert-Path $installDir

    Get-ChildItem $env:TMP/pgsql_binaries/pgsql/bin | ForEach-Object {
        Copy-Item $_.FullName $installDir
    }

    $path = [Environment]::GetEnvironmentVariable("PATH")

    if (!$path.Contains($installDir)) {
        Write-InfoMessage "Adding $installdir to PATH"

        $path += ";$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $path, "User")
    }

    Write-InfoMessage "Cleaning up..."

    Remove-Item $env:TMP/pgsql_binaries -Recurse -Force
    Remove-Item ~/Downloads/pgsql_binaries.zip

    Write-OkMessage "Done"
}

function Remove-PostgresClient {
    if (!(Test-Command "psql")) {
        Write-ErrorMessage "Cannot find current postgres binaries directory for removal, is it added to PATH?"
        return -1
    }

    $binDir = Convert-Path(Join-Path(Get-Command "psql").Path "..")

    if ((Read-Host "Remove installation at $($binDir)? [y/N]").ToLower() -eq "y") {
        Remove-Item $binDir -Recurse -Force

        $path = [Environment]::GetEnvironmentVariable("PATH")

        if ($path.Contains($binDir)) {
            Write-InfoMessage "Removing $binDir from PATH"

            $path = $path.Replace(";$binDir", "")
            [Environment]::SetEnvironmentVariable("PATH", $path, "User")
        }
    }
}