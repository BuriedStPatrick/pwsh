# If user doesn't have ssh in PATH, write error and exit
@('ssh', 'ssh-add', 'ssh-keygen', 'ssh-agent') | ForEach-Object {
    if (!(Test-Command $_)) {
        Write-ErrorMessage "$_ not found in PATH, Ssh module disabled"
        return
    }
}

function Set-GitEnvironmentVars {
    # Set git SSH agent to whatever is set as the ssh agent in the PATH
    $env:GIT_SSH=$((Get-Command -Name ssh).Source)
}

function Start-WindowsSshAgent {
    if (!(Get-Process | Where-Object { $_.Name -eq 'ssh-agent'})) {
        $startupType = (Get-Service ssh-agent).StartType
        if(($startupType -eq "Disabled")) {
            if(!(Test-IsAdministrator)) {
                Write-ErrorMessage "Your OpenSSH Authentication Agent service is Disabled, need to change into StarupType: Manual, please try again as admin!"
            } else {
                Write-InfoMessage "Set OpenSSH Authentication Agent service to manual, was disabled."
                Get-Service ssh-agent | Set-Service -StartupType "Manual"
            }
        }

        Start-WindowsSshAgent
    }
}

# Set environment variables for git
Set-GitEnvironmentVars

# If running in Windows, start the OpenSSH agent service if it's not already running.
if ($IsWindows) {
    Start-WindowsSshAgent
}

# For each ssh-agent connection, add the specified public key to the agent.
Get-ChildItem -Path $HOME/.ssh/id_* -Recurse `
    | Where-Object { !($_.Extension -like '.pub') } `
    | ForEach-Object { ssh-add $_.FullName }