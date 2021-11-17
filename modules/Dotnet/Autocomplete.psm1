# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
       [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -Native -CommandName puma -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)

    puma complete $commandName | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }

    # @('database', 'repo') | ForEach-Object {
    #     [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    # }
}