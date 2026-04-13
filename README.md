# bashgit

A portable bash toolkit to simplify git workflows.

## Requirements
- bash
- git

## Install
```bash
git clone https://github.com/yourusername/bashgit.git
cd bashgit
bash install
```

## Usage

### `gi` — Initialize a repo
```bash
gi
```
Sets up a new git repo, optionally renames branch, creates .gitignore, README, and initial commit.

### `gacp` — Stage, commit and push
```bash
gacp          # stage all, prompt for commit message
gacp -a "msg" # stage all with message
gacp file.txt "msg" # stage specific file
```

## Roadmap
- [ ] v2: file groups for selective staging
- [ ] `gbranch` — branch management script