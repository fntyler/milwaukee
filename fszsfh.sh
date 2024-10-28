#!/usr/bin/env bash

# WIP
# ssh sessionizer using tmux

function _log() {
    local DATE
    local LOG_LEVEL
    local LOG_FILE
    local LOG_MESSAGE

    DATE=$(date '+%Y-%m-%d %T')
    LOG_LEVEL=${1:-'INFO'}
    LOG_FILE=${2:-/tmp/fszsfh.log}

    read -r LOG_MESSAGE
    echo "$DATE [$LOG_LEVEL] ${LOG_MESSAGE}" >> "$LOG_FILE"
}

function _sshcmd() {
    # WIP
    local REMOTE_HOST

    REMOTE_HOST=${1}

    ssh -oUser=fnt -oHost="$REMOTE_HOST" -oPort=22
}

declare -A CHOICES

export FZF_DEFAULT_OPTS="--color=bg+:#D9D9D9,bg:#E1E1E1,border:#C8C8C8,spinner:#719899,hl:#719872,fg:#0388A6,header:#719872,info:#150023,pointer:#E12672,marker:#E17899,fg+:#0388A6,preview-bg:#D9D9D9,prompt:#0099BD,hl+:#024059,query:#024059 \
    --border \
    --reverse"


# main

if [ -e "$HOME/.fszsfh.txt" ]; then
    . "$HOME/.fszsfh.txt" && \
        echo "Sourced $HOME/.fszsfh.txt " | _log "$@"
fi

CHOICES+=( [localhost]='127.0.0.1' )
#echo "${CHOICES[@]}"

CHOICE=$(for i in "${!CHOICES[@]}"; do echo "$i"; done | fzf)

#test -n "$CHOICE" && echo "${CHOICE}" || echo "[ ${CHOICE} ] is null" | _log 'WARN'
#test -n "$CHOICE" && _sshcmd "$CHOICE" || echo "[ ${CHOICE} ] is null" | _log 'WARN'

#echo "${CHOICES[$CHOICE]}"


tmux_proc=$(pgrep tmux | tr \\n _)

[ -z "$TMUX" ] && [ -z "$tmux_proc" ] && \
    tmux new-session -s "ssh-$CHOICE" -c "$HOME" "${CHOICES[$CHOICE]}" && exit 70

if ! tmux has-session -t "ssh-$CHOICE" 2>/dev/null; then
    tmux new-session -ds "ssh-$CHOICE" -c "$HOME" "${CHOICES[$CHOICE]}" \; attach && exit 70
fi

# If -d is specified, any other clients attached to the session are detached.
# If -x is given, send SIGHUP to the parent process of the client as well as detaching the client, typically causing it to exit.
tmux attach-session -dx -t "ssh-$CHOICE" && exit 70
