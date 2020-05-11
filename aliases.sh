#!/bin/sh

alias nsh='PATH="$NPATH" sh'
alias ls='ls --color'
alias f='less +IF -#30 -S -r -c -F -f'
alias iec-i='numfmt --to=iec-i --from=iec-i'
alias dockerpf='ssh -fNn -L 2424:/var/run/docker.sock'
alias kw='kops_wrapper kops.out.env'
alias jqdk="jq -er '.data | keys'"
alias jqd="jq  -er '.data[\$key] | @base64d' --arg key"
alias yml='yaml.py | nvim - -c "set ft=yaml"'

gittop() {
  local CDPATH
  CDPATH="$(git top)"
  CDPATH="$CDPATH" cd "${@:-$CDPATH}"
}

