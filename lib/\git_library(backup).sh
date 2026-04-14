#!/usr/bin/env bash

# ============================================================
# 🧠 USER INTERACTION UTILITIES
# ============================================================

# promptYN
# Prompt user with a Yes/No question until valid input is given.
#
# Arguments:
#   $1 - Optional custom message (default: "Want to continue?")
#
# Returns:
#   0 → Yes
#   1 → No
promptYN() {
    local msg="${1:-"Want to continue?"}"
    local ans=

    while true; do
        read -rp "$msg [Y/n]: " ans
        case $ans in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Invalid input. Enter Y or N." ;;
        esac
    done
}

# ============================================================
# 📁 REPOSITORY SETUP
# ============================================================

# repoExists
# Check if current directory is a Git repository.
#
# Returns:
#   0 → Repo exists
#   1 → Not a repo
repoExists() {
    [ -d ".git" ]
}

# createRepo
# Initialize a Git repository if one does not already exist.
createRepo() {
    if repoExists; then
        echo "Repo already exists" >&2
        return 1
    fi

    git init -q || return 1
}

# ============================================================
# 🌿 BRANCH MANAGEMENT
# ============================================================

# branchName
# Display current branch and optionally rename it.
branchName() {
    local branch
    local newBranch

    branch=$(git branch --show-current)
    branch="${branch:-"(no branch yet)"}"

    echo "Current branch: $branch"

    if promptYN "Change branch name?"; then
        read -rp "Enter new branch name: " newBranch
        newBranch="${newBranch:-main}"

        git branch -m "$newBranch" || return 1
        echo "Branch renamed to: $newBranch"
    fi
}

# ============================================================
# 📄 FILE BOILERPLATE
# ============================================================

# createGitignore
# Create .gitignore if missing.
createGitignore() {
    if [ -f ".gitignore" ]; then
        echo ".gitignore already exists" >&2
        return 1
    fi

    touch .gitignore || return 1
    echo "Created .gitignore"
}

# createReadme
# Create README.md if missing.
createReadme() {
    if [ -f "README.md" ]; then
        echo "README.md already exists" >&2
        return 1
    fi

    touch README.md || return 1
    echo "Created README.md"
}

# ============================================================
# 🔍 REPOSITORY STATE
# ============================================================

# hasCommits
# Check if repository has at least one commit.
#
# Returns:
#   0 → Has commits
#   1 → No commits yet
hasCommits() {
    git rev-parse --verify HEAD >/dev/null 2>&1
}

# ============================================================
# 📦 STAGING OPERATIONS
# ============================================================

# stageFiles
# Stage files based on mode.
#
# Usage:
#   stageFiles <file>       → stage single file
#   stageFiles -a           → stage all files
#   stageFiles -aq          → stage all quietly
#   stageFiles -q <file>    → stage file quietly
#   stageFiles -ex <group>  → stage all except group
stageFiles() {
    local mode="$1"
    local fileName="$2"
    local stagedFiles

    if [[ -z "$mode" ]]; then
        echo "Usage:"
        echo "  stageFiles <file>"
        echo "  stageFiles -a"
        echo "  stageFiles -aq"
        echo "  stageFiles -q <file>"
        echo "  stageFiles -ex <group>"
        return 1
    fi

    case "$mode" in
        -a)
            git add .
            stagedFiles=$(git diff --name-only --cached)
            echo "Staged files:"
            echo "$stagedFiles"
            ;;

        -aq)
            git add .
            ;;

        -q)
            if [[ -z "$fileName" || ! -f "$fileName" ]]; then
                echo "Invalid file: $fileName" >&2
                return 1
            fi
            git add "$fileName"
            ;;

        -ex)
            local groupFile=".bashgit/groups/$fileName"

            if [[ -z "$fileName" || ! -f "$groupFile" ]]; then
                echo "Group not found: $fileName" >&2
                return 1
            fi

            git status --porcelain \
                | awk '{print $2}' \
                | grep -v -F -f "$groupFile" \
                | xargs -r git add

            echo "Staged everything except group: $fileName"
            ;;

        *)
            if [[ -f "$mode" ]]; then
                git add "$mode"
                stagedFiles=$(git diff --name-only --cached)
                echo "$stagedFiles"
            else
                echo "Invalid file: $mode" >&2
                return 1
            fi
            ;;
    esac
}

# ============================================================
# 📝 COMMIT & PUSH
# ============================================================

# commitChanges
# Commit staged changes with message.
commitChanges() {
    local message="$1"

    if [[ -z "$message" ]]; then
        read -rp "Commit message: " message
    fi

    git commit -m "$message" || return 1
}

# pushChanges
# Push to remote, optionally setting upstream.
pushChanges() {
    git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        git push
        return 0
    fi

    if promptYN "Set upstream?"; then
        local remote branch

        read -rp "Remote: " remote
        read -rp "Branch: " branch

        remote="${remote:-origin}"
        branch="${branch:-$(git branch --show-current)}"

        git push -u "$remote" "$branch"
    else
        echo "Push aborted (no upstream)" >&2
        return 1
    fi
}

# gitPush
# Convenience function: stage → commit → push
gitPush() {
    local stageArgs="${1:-"-a"}"
    local commitMsg="${@:2}"

    if ! hasCommits; then
        echo "No commits yet. Make an initial commit first." >&2
        return 1
    fi

    stageFiles "$stageArgs" &&
    commitChanges "$commitMsg" &&
    pushChanges &&
    echo "Push successful"
}

# ============================================================
# 📂 GROUP MANAGEMENT
# ============================================================

# grpCreate
# Create a new file group.
grpCreate() {
    local groupName="$1"
    local groupDir=".bashgit/groups"

    if ! repoExists; then
        echo "Not inside a Git repo" >&2
        exit 1
    fi

    [[ -z "$groupName" ]] && read -rp "Group name: " groupName

    mkdir -p "$groupDir" || return 1

    if [[ -f "$groupDir/$groupName" ]]; then
        echo "Group exists: $groupName" >&2
        return 1
    fi

    touch "$groupDir/$groupName"
    echo "Created group: $groupName"
}

# grpAdd
# Add file to group.
grpAdd() {
    local groupName="$1"
    local fileName="$2"
    local groupFile=".bashgit/groups/$groupName"

    if [[ ! -f "$groupFile" ]]; then
        echo "Group not found: $groupName" >&2
        return 1
    fi

    if ! grep -qxF "$fileName" "$groupFile"; then
        echo "$fileName" >> "$groupFile"
        echo "Added $fileName → $groupName"
    else
        echo "$fileName already in $groupName" >&2
        return 1
    fi
}

# grpList
# List all groups.
grpList() {
    ls ".bashgit/groups" 2>/dev/null || echo "No groups found"
}

# grpShow
# Show contents of a group.
grpShow() {
    local name="$1"
    local groupFile=".bashgit/groups/$name"

    [[ -z "$name" ]] && read -rp "Group name: " name

    if [[ -f "$groupFile" ]]; then
        cat "$groupFile"
    else
        echo "Group not found: $name" >&2
        return 1
    fi
}

# ============================================================
# 🚀 ENTRY POINT
# ============================================================

# Execute only when script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    promptYN "Create a .gitignore?"
fi