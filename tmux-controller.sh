#!/usr/bin/env bash

# tmux controller used to manage tmux sessions
# inspired by https://github.com/ThePrimeagen/.dotfiles - tmux-sessionizer

if [ $# -eq 1 ]; then
    target_dir=${1}
else
    target_dir=$(find ~/dev -maxdepth 1 -mindepth 1 -type d | fzf)
fi

if [ -z "$target_dir" ]; then
    exit 70
fi

target_selected=$(basename "$target_dir")

tmux_proc=$(pgrep tmux | tr \\n _)

[ -z "$TMUX" ] && [ -z "$tmux_proc" ] && \
    tmux new-session -s "$target_selected" -c "$target_dir" && exit 70

if ! tmux has-session -t "$target_selected" 2>/dev/null; then
    tmux new-session -ds "$target_selected" -c "$target_dir"
fi

tmux switch-client -t "$target_selected"
