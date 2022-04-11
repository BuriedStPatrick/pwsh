# PWSH Profile

A collection of configurable PowerShell modules. Individual modules can be turned on/off via a YAML configuration file.

## Installation

1. Clone repository
2. Run `patch.ps1` and pick the first option to install.
3. Choose "yes" for sourcing the profile if asked.

This will copy the modules and scripts from the repository into your HOME-directory. Sourcing the profile will invoke the pwshrc.ps1 script inside your PowerShell profile. To see where it's located, type `$PROFILE` in your PowerShell terminal. Look for a line with the comment `# < PWSH` to see the line the patch install added. Uninstalling will also give you the option to remove the line again if you want.

> There's some weirdness with adding/removing lines when sourcing. I haven't found a good solution to this that works on every platform and line-ending style, but the worst that can happen right now is that you get a few extra lines in your `$PROFILE` if you re-install a lot.

### Dependencies

In case you want everything to work and not have to tweak, make sure you have following installed:

* `git`
* `gitui`
* `fzf`
* `starship` and/or `oh-my-posh`
* `lf`
* `vim` and/or `neovim`
* `openssh` (Only tested on Windows so far)
* `dotnet`
* `yq` (Required for combing user config with default config)

None of these are required, but some module features will not work without them.

## Configuration

Once you're running with the profile-script, you can check your current configuration by calling the `Get-Config` function. To see the default configuration, you can open it with your preferred text editor like so:

```powershell
# Simply output the config in the terminal
cat $env:PWSH_HOME/pwsh.yaml

# Open with a text editor
notepad $env:PWSH_HOME/pwsh.yaml
vim $env:PWSH_HOME/pwsh.yaml
```

Do *NOT* edit the file. It will work, but I highly recommend creating a separate config-file and placing it inside `$env:PWSH_CONFIG`. This way, you can override only the options you're interested in and leave the default values out of your own configs. You can always see the finalized config via `Get-Config`.

A quick way to add the config file is to run `patch.ps1` and picking the third option to copy the default config. Although I recommend stripping it of everything you don't intend on changing to make future upgrades less painful if default values change.

You can very quickly open the config-file using `Ctrl+.` in your PowerShell session. Although be aware that this uses the `$env:EDITOR` environment variable to determine the default editor to open files. I personally use neovim, which might not be ideal for well-adjusted people. You may want to set it to something like `notepad` or `code` depending on your preference. See [Environment variables](#environment-variables) section for more info.

## Modules

The different modules have certain dependencies, and some of them might not be relevant to you. They are all disabled by default (Except `Core`). You can enabled them by setting the `modules.<MODULE-NAME>.enabled` property to true in the config.

## Keybindings

These are all the keybindings I've set:

|  Binding | Module        | Does                                                                                                                                                                                                                   |
|----------|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Ctrl+.` | Core          | Opens the user's `pwsh.yaml` config file with the default `$env:EDITOR`                                                                                                                                                |
| `Ctrl+f` | FuzzyFinder   | Runs `fzf` in the current directory, navigate with arrows/text search. On exit, cd's into the directory. If a file is selected, opens that file with the default app.                                                  |
| `Ctrl+h` | Misc          | Pipes command history into `fzf`, executes on selection                                                                                                                                                                |
| `Ctrl+o` | Lf            | Runs `lf`, on exit cd's to current selected directory                                                                                                                                                                  |
| `Ctrl+p` | PasswordState | Looks for PasswordState lists, pipes into `fzf`. On Password List selected, looks for passwords within the selected list and pipes into `fzf`. On Password selected, copies to clipboard. Ids of passwords are cached. |
| `Ctrl+g` | Git           | Starts `gitui` in the current directory                                                                                                                                                                                |
| `Ctrl+b` | Git           | Looks for local branches and, pipes into `fzf`. On selected branch, performs `git checkout` on that branch.                                                                                                            |
| `Ctrl+m` | Git           | Looks for local branches and, pipes into `fzf`. On selected branch, performs `git merge` on that branch.                                                                                                               |
| `Ctrl+k` | Kubectl       | Switch current kubectl context using `fzf`.                                                                                                                                                                            |
