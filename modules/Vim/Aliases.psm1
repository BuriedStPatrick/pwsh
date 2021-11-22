$config = (Get-Config)?.modules?.Vim?.config

if ($null -eq $config) {
    return
}

$editor = $config.useNeovim `
    ? "nvim" `
    : "vim"

if ($config.setDefaultEditor) {
    $env:EDITOR = $editor
}

if ($config.useNeovim) {
    Set-Alias vim nvim
}
