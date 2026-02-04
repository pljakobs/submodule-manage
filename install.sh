#!/bin/bash

# Installer script for git-submodule-manage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_NAME="git-submodule-manage"
INSTALL_PATH="/usr/local/bin/$BIN_NAME"
COMPLETIONS_DIR="$SCRIPT_DIR/completions"

echo "Installing git-submodule-manage..."

# 1. Install the main script
if [ -w "/usr/local/bin" ]; then
    echo "Copying script to /usr/local/bin..."
    cp "$SCRIPT_DIR/$BIN_NAME" "$INSTALL_PATH"
else
    echo "This script requires sudo privileges to copy to /usr/local/bin"
    sudo cp "$SCRIPT_DIR/$BIN_NAME" "$INSTALL_PATH"
fi

sudo chmod +x "$INSTALL_PATH"
echo "✅ Script installed to $INSTALL_PATH"

# 2. Detect shell and install completions
# We check the PREFERRED user shell, not the running one (which is bash due to shebang)
USER_SHELL=$(basename "$SHELL")
echo "Detected user shell preference: $USER_SHELL"

# Install for Bash (always good to have if bash is installed)
if command -v bash >/dev/null; then
    echo "Configuring for Bash..."
    BASH_COMPLETION_DIR="/etc/bash_completion.d"
    
    if [ -d "$BASH_COMPLETION_DIR" ]; then
        echo "Installing Bash completions to $BASH_COMPLETION_DIR..."
        if [ -w "$BASH_COMPLETION_DIR" ]; then
            cp "$COMPLETIONS_DIR/git-submodule-manage.bash" "$BASH_COMPLETION_DIR/git-submodule-manage"
        else
            sudo cp "$COMPLETIONS_DIR/git-submodule-manage.bash" "$BASH_COMPLETION_DIR/git-submodule-manage"
        fi
        echo "✅ Bash completions installed."
    else
        # Fallback for user-local bash completion
        USER_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
        mkdir -p "$USER_COMPLETION_DIR"
        cp "$COMPLETIONS_DIR/git-submodule-manage.bash" "$USER_COMPLETION_DIR/git-submodule-manage"
        echo "✅ Bash completions installed to user directory: $USER_COMPLETION_DIR"
    fi
    
    # Register the completion
    BASHRC="$HOME/.bashrc"
    if grep -q "original git completion function" "$COMPLETIONS_DIR/git-submodule-manage.bash"; then
         # This part is a bit tricky since we rely on git's completion being loaded first.
         # For now, we will add a source line if it's not system-wide
         if [ ! -d "/etc/bash_completion.d" ]; then
             if ! grep -q "git-submodule-manage.bash" "$BASHRC"; then
                 echo "" >> "$BASHRC"
                 echo "# git-submodule-manage completion" >> "$BASHRC"
                 echo "source $USER_COMPLETION_DIR/git-submodule-manage" >> "$BASHRC"
                 echo "✅ Added source command to $BASHRC"
             fi
         fi
    fi
    
    # We also need to register the completion in the bashrc if standard bash-completion loader is not present,
    # but usually /etc/bash_completion.d files are auto-loaded.
    # To be safe for custom install, we add a proper completion registration block.
    
    # We need to tell bash to allow this completion for 'git submodule-manage'
    # Actually wait - git subcommands are tricky. 
    # Usually git handles completions for known subcommands via specific functions named _git_command.
    # The provided bash completion script defines `_git_submodule_manage`.
    # Git's main completion script looks for that function execution.
    # So simply sourcing the file defining `_git_submodule_manage` is usually enough IF git completion is loaded.
    
    # The script looks like it defines _git_submodule_manage but doesn't register it with `complete`.
    # This is correct for git subcommands - git's main completion calls it dynamically.
fi

# Install for Fish (if fish is installed)
if command -v fish >/dev/null; then
    echo "Configuring for Fish..."
    FISH_COMPLETION_DIR="$HOME/.config/fish/completions"
    mkdir -p "$FISH_COMPLETION_DIR"
    
    echo "Installing Fish completions to $FISH_COMPLETION_DIR..."
    cp "$COMPLETIONS_DIR/git-submodule-manage.fish" "$FISH_COMPLETION_DIR/git-submodule-manage.fish"
    echo "✅ Fish completions installed."
fi

# Install for Zsh (if zsh is installed)
if command -v zsh >/dev/null; then
    echo "Configuring for Zsh..."
    echo "⚠️  Zsh support is not fully implemented in this installer yet."
fi

echo ""
echo "Installation complete!"
echo "Please restart your shell or run 'source ~/.bashrc' (or equivalent) to enable completions."
