# Bashgit

A portable bash toolkit to simplify git workflows.

## Requirements

* bash
* git

## Install

```bash
git clone https://github.com/dimensionexpert/bashgit.git
cd bashgit
bash scripts/install
```

## Usage

### `gi` — Initialize a repo

```bash
gi
```

Sets up a new git repo, optionally renames branch, creates .gitignore, README, and initial commit.

### `gacp` — Stage, commit and push

```bash
gacp "msg"                    # stage all, commit and push
gacp -a "msg"                 # stage all explicitly
gacp -e groupname "msg"       # stage all except group
gacp -q "msg"                 # stage all quietly
gacp -eq groupname "msg"      # stage all except group, quietly
```

Automatically checks sync status before staging. Will prompt to set upstream if not set.

### `ga` — Stage files

```bash
ga -a                         # stage all
ga -e groupname               # stage all except group
ga file.txt                   # stage specific file
```

### `gc` — Commit

```bash
gc "msg"                      # commit with message
gc                            # prompts for message if not provided
```

### `gp` — Push

```bash
gp                            # push to upstream
```

Handles no-commits and no-upstream cases interactively.

### `grp` — Manage file groups

```bash
grp -c groupname              # create a group
grp -a groupname file.txt     # add file to group
grp -l                        # list all groups
grp -s groupname              # show files in group
```

Groups are stored in `.bashgit/groups/` in your project root.
Must be run from the root of a git repository.

### `gsync` — Check sync status

```bash
gsync
```

Checks whether your local branch is:

* up to date
* ahead (safe to push)
* behind (needs pull)
* diverged (requires manual resolution)

Also shows commit differences when applicable.

### `uninstall` — Remove bashgit

```bash
uninstall
```

Removes bashgit from your system by:

* deleting installed scripts
* removing PATH entries

Does not delete `.bashgit/` folders inside your projects.

## Backup

During install, Bashgit creates a backup of your shell configuration file.

Supported shells:

* bash → `~/.bashrc`
* zsh → `~/.zshrc`
* fish → `~/.config/fish/config.fish`

Backups are stored alongside the original file using the format:

```
<config>.bashgit.bak.<timestamp>
```

Example:

```
config.fish.bashgit.bak.2026-04-14_20-45-26
```

Backups are only created if the configuration file exists.

## Roadmap

* [x] `gi` — repo initialization
* [x] `gacp` — stage, commit, push with sync check
* [x] `ga` / `gc` / `gp` — granular git controls
* [x] `grp` — file group management
* [x] `gsync` — sync status check
* [x] `uninstall` — remove bashgit
* [ ] background fetch with throttling
* [ ] `gbranch` — branch management
