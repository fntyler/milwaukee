#!/bin/bash
# fzf menu - web browser
# keys are menu options, values are web-browser targets
# default-wm: i3
# default-browser: brave-browser

declare -A CHOICES

export FZF_DEFAULT_OPTS="--color=bg+:#D9D9D9,bg:#E1E1E1,border:#C8C8C8,spinner:#719899,hl:#719872,fg:#0388A6,header:#719872,info:#150023,pointer:#E12672,marker:#E17899,fg+:#0388A6,preview-bg:#D9D9D9,prompt:#0099BD,hl+:#024059,query:#024059 \
    --border \
    --reverse"

INCOGNITO='false'

function _i3cmd() {
    TARGET=$1
    IS_INCOGNITO=$2
    test -z $1 && exit 71
    if [[ $IS_INCOGNITO == 'false' ]]; then
        test $(i3-msg "exec --no-startup-id brave-browser --new-window $TARGET" 1>/dev/null 2>>/tmp/fuzzmenu.log) 
    else
        test $(i3-msg "exec --no-startup-id brave-browser --new-window --incognito $TARGET" 1>/dev/null 2>>/tmp/fuzzmenu.log)
    fi
}

if [ -e ~/.fuzzmenu_choices ]; then
    . ~/.fuzzmenu_choices
    echo '[INFO] Sourced ~/.fuzzmenu_choices' 2>&1 >> /tmp/fuzzmenu.log
else
    echo '[INFO] Missing ~/.fuzzmenu_choices' 2>&1 >> /tmp/fuzzmenu.log
fi

CHOICES+=( [github]='https://github.com/' )
CHOICES+=( [twilio]='https://console.twilio.com/us1/?frameUrl=/console' )
CHOICES+=( [pep8-python]='https://peps.python.org/pep-0008/' )
CHOICES+=( [localhost-8000-]='http:localhost:8000' )


#CHOICE=$(for i in ${!CHOICES[@]}; do echo $i; done | fzf -m --bind=ctrl-space:toggle)
CHOICE=$(for i in ${!CHOICES[@]}; do echo $i; done | fzf)

if [[ $CHOICE =~ .*-$ ]]; then INCOGNITO='true'; fi

test -z $CHOICE && exit 70

_i3cmd ${CHOICES[$CHOICE]} ${INCOGNITO}

unset FZF_DEFAULT_OPTS
