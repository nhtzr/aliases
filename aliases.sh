#!/bin/sh


alias ls='ls --color'
alias ll='ls -lah'
alias mv='mv -iv'

alias f='less +IF -#30 -S -r -c -F -f'
alias iec-i='numfmt --to=iec-i --from=iec-i'
alias tf=terraform
alias TF='TF_LOG=TRACE TF_LOG_PATH=.tflogt terraform'
alias docker-port-forward='ssh -fNn -L 2424:/var/run/docker.sock'
alias yml='yaml.py | nvim - -c "set ft=yaml"'
alias cd=pushd

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

