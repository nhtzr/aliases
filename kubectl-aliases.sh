alias randomid='printf "%s-%s" "$(whoami | tr -cd "[:alnum:]")" "$(date +%Y%m%d%H%M%S)"'
alias k='kubectl'

alias Kg='kubectl get --all-namespaces'
alias Kgp='kubectl get pod --all-namespaces'
alias Kgs='kubectl get service --all-namespaces'
alias Kgsa='kubectl get serviceaccount --all-namespaces'
alias Kgd='kubectl get deployment --all-namespaces'
alias Kgcm='kubectl get configmap --all-namespaces'
alias Kgcs='kubectl get secret --all-namespaces'
alias Kgi='kubectl get ingress --all-namespaces'

alias kg='kubectl get'
alias kgp='kubectl get pod'
alias kgs='kubectl get service'
alias kgsa='kubectl get serviceaccount'
alias kgd='kubectl get deployment'
alias kgcm='kubectl get configmap'
alias kgcs='kubectl get secret'
alias kgi='kubectl get ingress'

alias kd='kubectl describe'
alias kdd='kubectl describe deployment'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'

# The following are meant to be used with proc substitution. e.g.:
# $ less -F -f <(klf intg $(kgp intg -lname=intg-kong-kong -o name | head -n -1) )
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs -p'

alias kx='kubectl exec -it'
alias kr='kubectl run $(randomid) -it --rm --restart=Never --generator=run-pod/v1 --attach=true'
alias krun='kubectl run $(randomid) -it --rm --restart=Never --generator=run-pod/v1 --attach=true --labels user=$(whoami) --image=alpine:latest'

alias ke='kubectl edit'
alias ked='kubectl edit deployment'
alias kecm='kubectl edit configmap'

# v work around for kuebctl rollout restart
alias kr_='kubectl patch -p '"'$(jq -nc '.spec.updateStrategy.type="RollingUpdate" | .spec.updateStrategy.rollingUpdate.maxUnavailable=1 | .spec.minReadySeconds=40')'"
alias krr="kubectl patch -p \"\$(jq -n --arg date \"\$(date +%s)\" '.spec.template.metadata.annotations.lastRestart = \$date' )\""
alias krs='kubectl rollout status'

alias krmrfp='kubectl delete pod'
alias krmrfns='kubectl delete namespace'

alias kgns='kubectl get namespace'
alias kgno='kubectl get nodes'

alias ktop='kubectl top pods --containers=true --heapster-namespace=kube-system'
alias kcp='kubectl cp'
alias ksd='kubectl scale deployment --replicas'

kuse() {
  ## set kubeconfig
  local kubeconfig="${1?missing kube config file}"
  export KUBECONFIG="${HOME?}/.kube/${kubeconfig}${kubeconfig+/}config"
  echo "Switched to kubeconfig \"${kubeconfig}\"." &>/dev/stderr
  ## set context
  local ctx="${2:-}"  # kube context is optional
  if test -z "${ctx}"; then return; fi
  if ! kubecontext_exists "${ctx}" &>/dev/null; then
    local cluster="$(kubecontext_currentprop cluster)"
    local user="$(kubecontext_currentprop user)"
    local namespace="${ctx}"  # assume new context is named after the namespace
    kubectl config set-context "${ctx}" --cluster="${cluster:?}" --user="${user:?}" --namespace="${namespace:?}" &>/dev/stderr
  fi
  kubectl config use-context "${ctx}" &>/dev/stderr
}

kpf() {
  if [[ "$#" -lt 2 ]]; then
    echo "Usage kpf pod port" >/dev/stderr
    echo "Received:" "$@" >/dev/stderr
    return 1
  fi
  local pod="${1:?pod}"
  local pod_escaped="$(tr -cd ':[:alpha:]' <<< "$pod")"
  local nohup_file="$PWD/$pod_escaped.port-forward.out"
  local port="$( tr -cd ':[:digit:]' <<< "${2:?port}" )"
  local localport="${port%%:*}"
  shift
  shift

  (
    trap "rm -f '$nohup_file'" SIGTERM
    kubectl port-forward "${pod}" "$port" "$@" >"$nohup_file"
  )&
  local pid="$!"
  while true; do
    sleep 0
    if ! kill -0 "$pid" >/dev/null 2>&1; then
      cat "$nohup_file" >/dev/stderr
      rm "$nohup_file"  >/dev/null 2>&1
      return 1
    fi
    if nc -z -w5 localhost "${localport}" >/dev/stderr; then
      break
    fi
    sleep 2
  done

}


# Check files in cm and secrets
kls() { kubectl get "$@" -o json | jq -re '.data | keys' ; }
kcat() {
  /bin/sh -c "$(cat <<'EOF'
  kubectl get "${@:0:$#}" -o json | jq -re '.kind as $kind | .data[$key] | if $kind == "Secret" then @base64d else . end' --arg key "${!#}"
EOF
  )" _ "$@"
}

# Only for kubectl under idk what version
kubeportforward_for_service() {
  if ! test "$#" = "2"; then
    echo "Usage kpf service port" >&2
    echo "Received:" "$@" >&2
    return 1
  fi
  local svc="${1:?service}"
  local port="${2:?port}"
  shift
  shift
  local pod_selectors="$( kubeselectors_of_service "$svc" "$@" )"
  if test -z "${pod_selectors:-}"; then return 1; fi
  local pod="$(
    kubectl get pod -l "$pod_selectors" "$@" -o name | head -n 1
  )"
  if test -z "${pod:-}"; then return 1; fi
  kpf "$pod" "$port" "$@"
}

kubeselectors_of() {
  for resource in "$@"; do
    case "$resource" in
      service/* | svc/*)
        kubeselectors_of_service "${resource#*/}"
        ;;
      deployment*/*)
        kubeselectors_of_deployment "${resource#*/}"
        ;;
      pod/*)
        kubeselectors_of_pod "${resource#*/}"
        ;;
    esac
  done
}

kubeselectors_of_deployment() {
  kubectl get deployment "$@" -o json | jq -r '.spec.selector.matchLabels | to_entries | map("\(.key)=\(.value)") | join(",") '
}

kubeselectors_of_service() {
  kubectl get service "$@" -o json | jq -r '.spec.selector | to_entries | map("\(.key)=\(.value)") | join(",") '
}

kubeselectors_of_pod() {
  kubectl get pod "$@" -o json | jq -r '.metadata.labels | to_entries | map(select(.key != "pod-template-hash") | "\(.key)=\(.value)") | join(",") '
}


kubecontext_currentprop() {
  local prop="${1?prop missing}"
  local ctx="${CTX:-}"
  if test -z "${ctx}"; then
    ctx="$(kubectl config current-context)"
  fi
  kubectl config view -o json |
    jq -r '.contexts[] | select(.name == $currentcontext).context[$prop]' --arg currentcontext "$ctx" --arg prop "${prop}"
}

kubecontext_exists() {
  kubectl config view -o json |
    kubectl config view -o json | jq -e '.contexts[] | select(.name == $name) | objects' --arg name "${1?}"
}

