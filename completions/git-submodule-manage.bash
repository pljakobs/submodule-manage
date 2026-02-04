# Bash completion for git-submodule-manage

_git_submodule_manage() {
    local subcommands="add remove update reset diff shallow checkout set-url add-remote info list"
    
    # Use standard git completion helper if available
    local subcommand=""
    if type __git_find_on_cmdline >/dev/null 2>&1; then
        subcommand="$(__git_find_on_cmdline "$subcommands")"
    else
        # Fallback simplistic parsing
        local word
        for word in "${COMP_WORDS[@]}"; do
            if [[ " $subcommands " =~ " $word " ]]; then
                subcommand="$word"
                break
            fi
        done
    fi

    if [ -z "$subcommand" ]; then
        if type __gitcomp >/dev/null 2>&1; then
            __gitcomp "$subcommands"
        else
            COMPREPLY=( $(compgen -W "$subcommands" -- "${COMP_WORDS[COMP_CWORD]}") )
        fi
        return
    fi

    # Helper to get submodules from .gitmodules
    local submodules
    submodules="$(git config -f .gitmodules --get-regexp path 2>/dev/null | awk '{print $2}')"

    case "$subcommand" in
        remove|update|reset|diff|info|shallow)
             if type __gitcomp >/dev/null 2>&1; then
                __gitcomp "$submodules --commit"
             else
                local suggestions="$submodules"
                if [[ " remove update " =~ " $subcommand " ]]; then
                    suggestions="$suggestions --commit"
                fi
                COMPREPLY=( $(compgen -W "$suggestions" -- "${COMP_WORDS[COMP_CWORD]}") )
             fi
            ;;
        checkout)
            # First arg is branch, second is submodule. 
            local cur="${COMP_WORDS[COMP_CWORD]}"
            local prev="${COMP_WORDS[COMP_CWORD-1]}"
            
            if [ "$prev" = "checkout" ]; then
                 if type __git_refs >/dev/null 2>&1; then
                    __gitcomp_nl "$(__git_refs)"
                 fi
            elif [[ " $submodules " =~ " $prev " ]]; then
                 # If previous word was a submodule, next is likely --commit
                 if type __gitcomp >/dev/null 2>&1; then
                    __gitcomp "--commit"
                 else
                     COMPREPLY=( $(compgen -W "--commit" -- "$cur") )
                 fi
            else
                 if type __gitcomp >/dev/null 2>&1; then
                    __gitcomp "$submodules"
                 else
                    COMPREPLY=( $(compgen -W "$submodules" -- "$cur") )
                 fi
            fi
            ;;
        set-url)
            # set-url <url> <submodule>
            local prev="${COMP_WORDS[COMP_CWORD-1]}"
            if [ "$prev" != "set-url" ]; then
                if type __gitcomp >/dev/null 2>&1; then
                    __gitcomp "$submodules"
                else
                    COMPREPLY=( $(compgen -W "$submodules" -- "${COMP_WORDS[COMP_CWORD]}") )
                fi
            fi
            ;;
        add-remote)
            # add-remote <name> <url> <submodule>
            local prev="${COMP_WORDS[COMP_CWORD-1]}"
            # Heuristic: if prev starts with http or git@, next is likely submodule
            # Or if word index > X
             subcmd_idx=0
             for ((i=0; i < ${#COMP_WORDS[@]}; i++)); do
                if [ "${COMP_WORDS[i]}" = "add-remote" ]; then
                    subcmd_idx=$i
                    break
                fi
             done
             
             # Name is idx+1, URL is idx+2, Submodule is idx+3
             current_idx=$COMP_CWORD
             relative_idx=$((current_idx - subcmd_idx))
             
             if [ $relative_idx -eq 3 ]; then
                if type __gitcomp >/dev/null 2>&1; then
                    __gitcomp "$submodules"
                else
                    COMPREPLY=( $(compgen -W "$submodules" -- "${COMP_WORDS[COMP_CWORD]}") )
                fi
             fi
            ;;
    esac
}
