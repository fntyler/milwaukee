#!/usr/bin/env bash
# fzf menu - web browser
# keys are menu options, values are web-browser targets
# default-wm: i3
# default-browser: brave-browser


function _determine_browser() {
        BROWSER='firefox'
}

function _i3cmd() {
    local SELECTED_CHOICE
    local DETERMINED_BROWSER
    local IS_INCOGNITO

    SELECTED_CHOICE=${1}
    DETERMINED_BROWSER=${2}
    IS_INCOGNITO=${3}

    test -z "$1" && exit 71

    if [[ $IS_INCOGNITO == 'false' ]]; then
        test $(i3-msg "exec --no-startup-id ${DETERMINED_BROWSER} --new-window ${SELECTED_CHOICE}" && \
            echo "Opened ${SELECTED_CHOICE}" | _log "$@")
    else
        test $(i3-msg "exec --no-startup-id ${DETERMINED_BROWSER} --new-window --incognito ${SELECTED_CHOICE}" && \
            echo "Opened ${SELECTED_CHOICE} as incognito" | _log "$@")
    fi
}

function _log() {
    local DATE
    local LOG_LEVEL
    local LOG_FILE
    local LOG_MESSAGE

    DATE=$(date '+%Y-%m-%d %T')
    LOG_LEVEL=${1:-'INFO'}
    LOG_FILE=${2:-/tmp/fuzzmenu.log}

    read -r LOG_MESSAGE
    echo "$DATE [$LOG_LEVEL] ${LOG_MESSAGE}" >> "$LOG_FILE"
}


declare -A CHOICES

export FZF_DEFAULT_OPTS="--color=bg+:#D9D9D9,bg:#E1E1E1,border:#C8C8C8,spinner:#719899,hl:#719872,fg:#0388A6,header:#719872,info:#150023,pointer:#E12672,marker:#E17899,fg+:#0388A6,preview-bg:#D9D9D9,prompt:#0099BD,hl+:#024059,query:#024059 \
    --border \
    --reverse"

INCOGNITO='false'


# main

if [ -e "$HOME/.fuzzmenu_choices" ]; then
    . ~/.fuzzmenu_choices && \
        echo 'Sourced ~/.fuzzmenu_choices' | _log "$@"
else
    echo 'Missing ~/.fuzzmenu_choices' | _log "$@"
fi

CHOICES+=( [github]='https://github.com/' )
CHOICES+=( [twilio]='https://console.twilio.com/us1/?frameUrl=/console' )
CHOICES+=( [pep8-python]='https://peps.python.org/pep-0008/' )
CHOICES+=( [localhost-8000-]='http://localhost:8000' )


CHOICE=$(for i in ${!CHOICES[@]}; do echo $i; done | fzf)

if [[ $CHOICE =~ .*-$ ]]; then INCOGNITO='true'; fi

test -z $CHOICE && exit 70

_determine_browser

_i3cmd ${CHOICES[$CHOICE]} ${BROWSER} ${INCOGNITO}

unset FZF_DEFAULT_OPTS
