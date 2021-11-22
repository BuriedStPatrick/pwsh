# Change working dir in powershell to last dir in lf on exit.
#
# You need to put this file to a folder in $ENV:PATH variable.
#
# You may put this in one of the profiles found in $PROFILE.
function Invoke-Lfcd {
    $tmp = [System.IO.Path]::GetTempFileName()
    lf -last-dir-path="$tmp" $args
    if (Test-Path -PathType Leaf "$tmp") {
        $dir = Get-Content "$tmp"
        Remove-Item -Force "$tmp"
        if (Test-Path -PathType Container "$dir") {
            if ("$dir" -ne "$pwd") {
                Set-Location "$dir"
            }
        }
    }
}