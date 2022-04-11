# Add Git GNU-like utils to PATH on Windows
if ($IsWindows) {
    $env:Path += ";$(Join-Path $env:ProgramFiles "Git" "usr" "bin")"
}
