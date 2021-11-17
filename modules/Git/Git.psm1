# Functions
Function Invoke-GitCommitAndPush {
    git add --all
    git commit --all --message @args
    git push
}

Function Invoke-GitPushForce {
    git push --force-with-lease
}

Function Invoke-GitCommitAll {
    git add --all
    git commit --message @args
}

Function Invoke-GitCommit {
    git commit -m @args
}

Function Invoke-GitPushCommit {
    git add --all
    git commit --message @args
}

Function Invoke-GitPush {
    git push @args
}

Function Invoke-GitPushBranch {
    git push -u origin @args
}

Function Invoke-GitPull {
    git pull
}

Function Invoke-GitMerge {
    if ($args.count -lt 1) {
        $branch = Get-GitBranchWithPrompt
        if (! "" -eq $branch) {
            git merge $branch
        }
    } else {
        git merge @args
    }
}

Function Invoke-GitRebase {
    git rebase @args
}

Function Invoke-GitLastCommit {
    Write-Host "Latest commit:"
    git log -1 --pretty=%B
}

Function Get-GitBranchWithPrompt  {
    $branch = $(git branch | fzf --layout reverse-list)
    if (! "" -eq $branch) {
        return $branch.Trim()
    }

    return ""
}

Function Invoke-GitCheckout {
    if ($args.count -lt 1) {
        $branch = Get-GitBranchWithPrompt
        if (! "" -eq $branch) {
            git checkout $branch
        }
    } else {
        git checkout @args
    }
}

Function Invoke-GitUndoCommit {
    git reset --hard HEAD~1
}

Function Invoke-GitCreateBranch {
    git branch @args
    git checkout @args
}

Function Invoke-GitDeployTest {
    git checkout develop
    git merge $currentBranch
}

Function Invoke-GitDeployProd {
    git checkout master
    git merge $currentBranch
}

Function Invoke-GitCurrentBranch {
    $(git rev-parse --abbrev-ref HEAD)
}

Function Invoke-GitAffectedFiles {
    git diff --name-only @args $(git merge-base @args master)
}

Function Invoke-GitAddAll {
    git add --all
}

Function Invoke-GitStash {
    git stash save @args
}

Function Invoke-GitWorkingStatus {
    git status
}

Function Invoke-GitDeleteBranch {
    git branch @args -d
}

Function New-PullRequest {
    $url = Get-PullRequestUrl @args
    Start-Process $url
}

Function Get-PullRequestUrl(
    [string] $target = "master",
    [string] $remote = "origin",
    [string] $user = "eksponent") {
    Write-Host "Creating Bitbucket Pull Request.."

    $branchname = git branch --show-current
    if (@("master","develop","release","test") -contains $branchname) {
        Write-Host "Kan ikke lave pullrequests ud fra master, develop, test og release branches"
        return
    }

    $url = git remote get-url $remote

    if ($url.StartsWith('git@')) {
        $remoteSource = $url.Split(':')[0].Replace('git@', '')
    } elseif ($url.StartsWith('https://')) {
        $remoteSource = $url # this won't work right now, but eh??
    }

    $repos = $url.split('/')[-1]

    return "https://$remoteSource/$user/$repos/pull-requests/new?source=$branchname&dest=$target&t=1"
}


# Keybindings
Set-PSReadLineKeyHandler -Chord Ctrl+g -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('gitui')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+b -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-GitCheckout')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+m -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Invoke-GitMerge')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}