# Bashgit

A portable bash toolkit to simplify git workflows.

## Requirements

* bash
* git

## Install

```bash
git clone https://github.com/dimensionexpert/bashgit.git
cd bashgit
bash setup
```

## Usage

### `gi` — Initialize a repo

```bash
gi
```

Sets up a new git repo, optionally renames branch, creates .gitignore, README, and initial commit.

### `gacp` — Stage, commit and push

```bash
gacp                        # stage all, prompt for commit message
gacp -a "msg"               # stage all with message
gacp -aq "msg"              # stage all quietly
gacp file.txt "msg"         # stage specific file
gacp -q file.txt "msg"      # stage specific file quietly
gacp -ex groupname "msg"    # stage all except group
```

### `grp` — Manage file groups

```bash
grp -c groupname            # create a group
grp -a groupname file.txt   # add file to group
grp -l                      # list all groups
grp -s groupname            # show files in group
```

Groups are stored in `.bashgit/groups/` in your project root.
Must be run from the root of a git repository.

## Backup

During setup, Bashgit creates a backup of your shell configuration file.

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
- [x] `gi` — repo initialization
- [x] `gacp` — stage, commit, push
- [x] `grp` — file group management
- [ ] `gbranch` — branch management
- [ ] v2: improved group workflows