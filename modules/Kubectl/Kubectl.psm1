function Get-KubectlContexts {
    return ((kubectl config get-contexts --no-headers) | ForEach-Object { $_.Trim().Split(" ")[0] } | Where-Object { $_ -ne "*" })
}

function Invoke-KubectlFuzzySelectContext {
    Set-KubectlCurrentContext (Get-KubectlContexts | fzf --layout reverse --header "Select context")
}

function Set-KubectlCurrentContext($context) {
    kubectl config use-context $context
}

Set-PSReadLineKeyHandler -Chord Ctrl+k -Description "Kubectl: Switch cluster context" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-KubectlFuzzySelectContext')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}