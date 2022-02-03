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

    $remote = (git remote | head -1)

    if (Read-Boolean "Push to $remote as well?") {
        git push -u $remote @args
    }
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
    $currentBranch = (git branch --show-current)
    if ($currentBranch -eq $args[0]) {
        Write-ErrorMessage "Cannot delete current branch. Please switch to a diffent branch first."
        return;
    }

    git checkout $args[0] --quiet
    $remote = (git status -sb --porcelain | Select-Object -first 1 | ForEach-Object { $_.Split("...") | Select-Object -last 1 })
    $origin = (git remote | head -1)

    git checkout $currentBranch --quiet
    git branch -d $args[0] -D

    $originExists = $remote -and !($remote.StartsWith("## "))

    if ($originExists -and (Read-Boolean "Delete on $origin as well?")) {
        Write-InfoMessage "Deleting $args on $origin"
        git push $origin --delete $args
    }
}

Function Invoke-GitDeleteBranchesWithNoRemote {
    $branches = (git fetch -p && git branch -vv | awk '/: gone]/{print $1}')

    if ($branches.Length -gt 0) {
        Write-Host "Stale branches to delete (no origin):`n"
        $branches | ForEach-Object { Write-Host $_ }
        Write-Host

        if ((Read-Boolean "OK?")) {
            $branches | ForEach-Object {
                git branch -D $_
            }

            Write-OkMessage "Deleted all stale branches"
        } else {
            Write-InfoMessage "Aborted"
        }
    } else {
        Write-InfoMessage "No stale branches to delete"
    }
}
