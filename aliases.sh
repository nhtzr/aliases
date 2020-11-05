#!/bin/sh

alias nsh='PATH="$NPATH" sh'
alias ls='ls --color'
alias f='less +IF -#30 -S -r -c -F -f'
alias iec-i='numfmt --to=iec-i --from=iec-i'
alias tf=terraform
alias TF='TF_LOG=TRACE TF_LOG_PATH=.tflogt terraform'
alias dockerpf='ssh -fNn -L 2424:/var/run/docker.sock'
alias kw='kops_wrapper kops.out.env'
alias jqdk="jq -er '.data | keys'"
alias jqd="jq  -er '.data[\$key] | @base64d' --arg key"
alias yml='yaml.py | nvim - -c "set ft=yaml"'
alias _bgj_='jobs | awk -F"[][]" '\''{print "%"$2}'\'
alias bkill='if test -n "$(_bgj_)"; then kill $(_bgj_); fi'
cd_() { command pushd "${1:-$HOME}" &>/dev/null; };
alias cd=cd_

gittop() {
  local CDPATH
  CDPATH="$(git top)"
  CDPATH="$CDPATH" cd "${@:-$CDPATH}"
}

trim() {
  : "$(cat)"
  : "${_##${1:-}}"
  : "${_%%${2:-}}"
  printf '%s\n' "${_}"
}

reminder_date() {
  stat "${HOME:?}/.config/reminders/${1:?}" | awk '$1 ~ /Modify:/ {print $2}'
}

