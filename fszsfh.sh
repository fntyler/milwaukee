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

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#dbcbcb,fg+:#ffffff,bg:#161616,bg+:#161616
  --color=hl:#5f87af,hl+:#5fd7ff,info:#e7e723,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#52dede
  --color=border:#b8b8b8,query:#ffffff
  --border="rounded" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆"'

# main

if [ -e "$HOME/.fszsfh.txt" ]; then
    . "$HOME/.fszsfh.txt" && \
        echo "Sourced $HOME/.fszsfh.txt " | _log "$@"
fi

CHOICES+=( [localhost]='127.0.0.1' )

CHOICE=$(for i in "${!CHOICES[@]}"; do echo "$i"; done | fzf)

#test -n "$CHOICE" \
#    && echo Selected "${CHOICE} -> ${CHOICES[$CHOICE]}" | _log 'INFO' \
#    || echo "[ ${CHOICE} ] is null" | _log 'WARN' && exit 71

if [ -n "$CHOICE" ]; then
    echo Selected "${CHOICE} -> ${CHOICES[$CHOICE]}" | _log 'INFO'
else
    echo "Choice is null exiting..." | _log 'WARN' && exit 71
fi

if ! tmux -S /tmp/tmux-1000/sshtsock list-session -F "#{pid}" 2>/dev/null; then
    echo "New session -> ssh w/ new window ${CHOICE} command ${CHOICES[$CHOICE]}" | _log
    tmux -S /tmp/tmux-1000/sshtsock new-session -d -s "$CHOICE" "${CHOICES[$CHOICE]}"\; attach
fi

if tmux -S /tmp/tmux-1000/sshtsock has-session -t "$CHOICE" 2>/dev/null; then
    echo "sshtsock has session -> ssh creating new window ${CHOICE}" | _log
    tmux -S /tmp/tmux-1000/sshtsock attach-session -dx -t ${CHOICE}\; new-window "${CHOICES[$CHOICE]}" && exit 70
fi

echo "sshtsock new session $CHOICE -> ssh creating new window ${CHOICES[$CHOICE]}" | _log
#tmux -S /tmp/tmux-1000/sshtsock attach-session -dx \; new-session -d -s "$CHOICE" "${CHOICES[$CHOICE]}" \; attach-session -dx -t "$CHOICE"
