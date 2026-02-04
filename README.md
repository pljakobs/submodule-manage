# git-submodule-manage

A Git extension that makes working with submodules sane. 

## Rationale

Git submodules are powerful but notoriously difficult to manage. Common tasks like "switch this submodule to a branch" or "cleanly remove this submodule" often require complex, multi-step Git commands that are easy to get wrong (leaving your repository in a broken state).

`git-submodule-manage` wraps these complex operations into simple, intuitive commands. It automates the maintenance of `.gitmodules`, configuration synchronization, and working directory state, so you don't have to memorize plumbing commands.

## Features

- **Clean Removal:** Properly de-initializes and removes submodules without leaving ghost files in `.git/modules`.
- **Branch Tracking:** Switch a submodule to a branch and automatically update `.gitmodules` to track it.
- **Easy Updates:** Update submodules to the latest remote commit without memorizing `git submodule update --remote --merge`.
- **Shallow Clones:** Convert submodules to shallow clones (depth 1) to save disk space.
- **Enhanced Status:** View exactly what changed in a submodule (commit logs) instead of just hash differences.

## Installation

### Automatic Installation

The project includes an installer script that installs the binary and sets up shell autocompletion.

```bash
git clone https://github.com/yourusername/git-submodule-manage.git
cd git-submodule-manage
./install.sh
```

This will:
1. Copy `git-submodule-manage` to `/usr/local/bin/`.
2. Install tab-completion scripts for **Bash** and **Fish**.

### Manual Installation

Copy the script to somewhere in your `$PATH`:

```bash
cp git-submodule-manage /usr/local/bin/
chmod +x /usr/local/bin/git-submodule-manage
```

For autocompletion, source the scripts in `completions/` in your shell configuration.

## Usage

Once installed, you can use it just like a native Git command:

```bash
git submodule-manage <command> [arguments]
```

### Commands

#### Adding & Removing

**`add <url> <path> [branch]`**
Adds a new submodule. Optionally configures it to track a specific branch immediately.
```bash
git submodule-manage add https://github.com/foo/bar libs/bar main
```

**`remove <path>`**
The "missing" git command. Cleanly removes a submodule, de-initializes it, removes the git config, and deletes the directory.
```bash
git submodule-manage remove libs/bar
```

#### Daily Workflow

**`update <path>`**
Updates the submodule to the latest commit on the remote branch it is tracking.
```bash
git submodule-manage update libs/bar
```

**`checkout <branch> <path>`**
Switches the submodule to a specific branch and updates `.gitmodules` to ensure `git submodule update --remote` will follow this branch in the future.
```bash
git submodule-manage checkout feature/new-ui libs/bar
```

**`reset <path>`**
Resets the submodule to the exact commit recorded in the parent repository. Useful if you've been experimenting inside the submodule and want to get back to the "official" state.
```bash
git submodule-manage reset libs/bar
```

#### Inspection & Maintenance

**`info <path>`**
Shows detailed information about the submodule: current branch, configured remote URL, tracked branch in `.gitmodules`, and status.
```bash
git submodule-manage info libs/bar
```

**`diff <path>`**
Shows the commit log of changes between the currently checked out version of the submodule and the version recorded in the parent repo.
```bash
git submodule-manage diff libs/bar
```

**`shallow <path> <depth>`**
Converts an existing submodule to a shallow clone to save space.
```bash
git submodule-manage shallow libs/bar 1
```

**`set-url <url> <path>`**
Changes the origin URL of a submodule and syncs the configuration.
```bash
git submodule-manage set-url https://new-host.com/repo.git libs/bar
```

**`list`**
Lists all submodules.

## Concepts

### Tracking Branches
By default, Git submodules point to specific **commits** (detached HEAD). This tool encourages a workflow where submodules track **branches** (via `.gitmodules` `branch` setting). The `checkout` and `add` commands automatically configure this for you.

### Clean State
Commands like `remove` and `set-url` are designed to be atomic: they either succeed completely or fail early. They handle the internal housekeeping of the `.git` directory which users often forget.

## License

GPL v3