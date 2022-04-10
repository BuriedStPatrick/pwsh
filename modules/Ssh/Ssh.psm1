$sshConfig = (Get-Config).modules.Ssh
if (!($sshConfig?.enabled ?? $false)) {
    return
}

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

function Start-OpenSshAgent {
    if (!(Get-Process | Where-Object { $_.Name -eq 'ssh-agent'})) {
        $service = Get-Service ssh-agent

        if ($service.StartType -eq "Disabled") {
            if(!(Test-IsAdministrator)) {
                Write-ErrorMessage "Your OpenSSH Authentication Agent service is Disabled, need to change into StarupType: Manual, please try again as admin!"
            } else {
                Write-InfoMessage "Set OpenSSH Authentication Agent service StartupType to 'Manual'. Was '$($service.StartType)'."
                Get-Service ssh-agent | Set-Service -StartupType "Manual"
            }
        }

        if ($service.Status -eq "Stopped") {
            Get-Service ssh-agent | Start-Service
            return $true
        }

        return $false
    }
}

# Set environment variables for git
Set-GitEnvironmentVars

# If running in Windows, start the OpenSSH agent service if it's not already running.
if ($IsWindows) {
    if((Start-OpenSshAgent)) {
        # For each ssh-agent connection, add the specified public key to the agent.
        if ($sshConfig.config.keys.Length -gt 0) {
            $keys = $sshConfig.config.keys | ForEach-Object { Get-Item $_ }
            $currentlyAddedSshKeys = $(ssh-add -l)?.Split(" ")?[3]?.Replace("(", "").Replace(")", "").ToLower() ?? @()
            $keys | Where-Object { !($_.Name.Replace("id_", "") -in $currentlyAddedSshKeys) } | ForEach-Object {
                ssh-add $_.FullName
            }
        }
    }
} else {
    Write-ErrorMessage "Ssh-agent isn't support on non-Windows OS'es yet. Still working on it!"
    return
}
