# Fish completion for git-submodule-manage
# Copy this file to ~/.config/fish/completions/git-submodule-manage.fish

function __fish_git_submodule_manage_submodules
    # Fetch submodules from .gitmodules instead of status
    git config -f .gitmodules --get-regexp path 2>/dev/null | awk '{print $2}' | while read -l path
         set -l name (basename $path)
         echo -e "$path\t$name"
    end
end

# Register the submodule-manage command with git (if not already done by standard completions)

set -l subcommands add remove update reset diff shallow checkout remote info inspect list

# Complete subcommands - only show if no subcommand used yet
complete -f -c git -n '__fish_git_using_command submodule-manage; and not __fish_seen_subcommand_from $subcommands' -a "$subcommands"

# Submodule completion helper
# For commands where submodule is the first argument
set -l direct_submod_cmds remove update reset diff info inspect shallow
complete -f -c git -n "__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from $direct_submod_cmds" -a "(__fish_git_submodule_manage_submodules)"

# Add flags for inspect/info
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from inspect info' -l all -d "Apply to all submodules"
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from inspect info' -l recursive -d "Apply recursively"
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from inspect' -l fix -d "Attempt to fix issues"

# Add --commit flag for modifying commands
set -l modifying_cmds add remove update checkout remote
complete -f -c git -n "__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from $modifying_cmds" -l commit -d "Automatically commit changes"

# checkout <branch> <submodule>
# Argument 1 is branch (arbitrary string or git refs?), Argument 2 is submodule
# We complete submodule if we have at least 1 token after checkout
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from checkout; and __fish_is_nth_token 4' -a "(__fish_git_submodule_manage_submodules)"

# remote command text completions
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from remote' -a "add remove rename set-url get-url"
# We also want to complete submodules for remote command, but it's tricky because args position varies.
# For now, just offering submodule completion if 'remote' is present is better than nothing.
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from remote' -a "(__fish_git_submodule_manage_submodules)"


# set-url <url> <submodule>
# url is token 3, submodule is token 4
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from set-url; and __fish_is_nth_token 4' -a "(__fish_git_submodule_manage_submodules)"

# add-remote <name> <url> <submodule>
# name=3, url=4, submod=5
complete -f -c git -n '__fish_git_using_command submodule-manage; and __fish_seen_subcommand_from add-remote; and __fish_is_nth_token 5' -a "(__fish_git_submodule_manage_submodules)"
