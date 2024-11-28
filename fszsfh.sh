#!/usr/bin/env bash

# WIP
# tmux ssh sessionizer: f[s]z[s]f[h]
# inspired by https://github.com/ThePrimeagen/tmux-sessionizer

# requirements:
# - tmux
# - fzf

# logging functions
prepare_log() {
    local TYPE="$1"; shift
	local TEXT="$*"; if [ "$#" -eq 0 ]; then TEXT="$(cat)"; fi
	local DATETIME; DATETIME="$(date '+%Y-%m-%d %T')"
    local LOGFILE; LOGFILE='/tmp/fszsfh.log'
    echo "$DATETIME [$TYPE] $TEXT" | tee -a "$LOGFILE"
}

log_info() {
	prepare_log INFO "$@"
}

log_warn() {
	prepare_log WARN "$@" >&2
}

log_error() {
	prepare_log ERROR "$@" >&2
	exit 1
}

# global variables
sock_name='ssh'
sock_path="/tmp/tmux-1000/$sock_name"
declare -A CHOICES

# example of CHOICES in 'fszsfh.txt'
#CHOICES+=( [example]='ssh <user>@<example>:<port>' )
#CHOICES+=( [server]='ssh -oUser=<username> -oIdentityFile=<file> -oPort=<port> <hostname|ip>' )

# fzf theme
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
        log_info "Sourced $HOME/.fszsfh.txt"
fi

if [ -n "$1" ]; then
    log_info "$(basename "$0") executed with args $*"
    CHOICE="$1"; shift
    ACTION="$*"; if [ "$#" -eq 0 ]; then ACTION='new-window'; fi

fi

if [ -z "$CHOICE" ]; then
    CHOICE=$(for i in "${!CHOICES[@]}"; do echo "$i"; done | fzf)
fi

if [ -n "$CHOICE" ]; then
    log_info "Selected ${CHOICE} -> ${CHOICES[$CHOICE]}"
else
    log_warn "Choice is null exiting..." && exit 71
fi

tmuxpid=$(tmux -L "$sock_name" list-session -F "#{pid}" 2>/dev/null)

if [ -z "$tmuxpid" ]; then
    log_info "Create new-session -> $CHOICE"
    tmux -L "$sock_name" -S "$sock_path" new-session -s "$CHOICE" "${CHOICES[$CHOICE]}" && exit 70
fi

if ! tmux -L "$sock_name" -S "$sock_path" has-session -t "$CHOICE" 2>/dev/null; then
    log_info "No session exists create new-session -> $CHOICE"
    tmux -L "$sock_name" -S "$sock_path" new-session -d -s "$CHOICE" "${CHOICES[$CHOICE]}" \; switch-client -t "$CHOICE" && exit 70
fi

if [ -z "$ACTION" ]; then
    log_info "Attach to existing session -> $CHOICE"
    tmux -S "$sock_path" switch-client -t "$CHOICE" \; attach-session -dx -t "$CHOICE" && exit 70
else
    log_info "$ACTION in existing session -> ${CHOICES[$CHOICE]}"
    tmux -S "$sock_path" "$ACTION" "${CHOICES[$CHOICE]}"
fi

tmux -S "$sock_path" attach-session -dx -t "$CHOICE"
