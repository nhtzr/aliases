#!/bin/sh

alias apispecs='cd $HOME/workspace/liveramp/api-specs'
alias reslang_='cd $HOME/workspace/liveramp/reslang'


alias ls='ls --color'
alias l='ls -1t'
alias ll='ls -lah'
alias lt='ls -laht'
alias mv='mv -i -v'
alias grep='ugrep --exclude-dir={CVS,.svn,.git,.idea,node_modules,vendor,.config}'
alias xargs='xargs -r'

alias f='less +IF -#30 -S -r -c -F -f'
alias iec-i='numfmt --to=iec-i --from=iec-i'
alias tf=terraform
alias TF='TF_LOG=TRACE TF_LOG_PATH=.tflogt terraform'
alias docker-port-forward='ssh -fNn -L 2424:/var/run/docker.sock'
alias yml='yaml.py | nvim - -c "set ft=yaml"'
alias pushd='pushd > /dev/null'
alias popd='popd > /dev/null'

gittop() {
  local CDPATH
  CDPATH="$(git top)"
  cd "${@:-$CDPATH}"
}

trim() {
  : "$(cat)"
  : "${_##${1:-}}"
  : "${_%%${2:-}}"
  printf '%s\n' "${_}"
}

