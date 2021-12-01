function Get-KubectlContexts {
    return ((kubectl config get-contexts --no-headers).Replace("*", "") | awk '{print $1}')
}

function Invoke-KubectlFuzzySelectContext {
    Set-KubectlCurrentContext (Get-KubectlContexts | fzf --layout reverse --height 20% --header "Select context")
}

function Set-KubectlCurrentContext($context) {
    kubectl config use-context $context
}

Set-PSReadLineKeyHandler -Chord Ctrl+k -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-KubectlFuzzySelectContext')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
}