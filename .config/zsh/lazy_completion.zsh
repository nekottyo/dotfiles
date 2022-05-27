#completion zsh
#exists "kubectl"   && . <(kubectl completion zsh)
#exists "helm"      && . <(helm completion zsh)
#exists "stern"     && . <(stern --completion zsh)
#exists "minikube"  && . <(minikube completion zsh)
#exists "direnv"    && . <(direnv hook zsh)
#exists "skaffold"  && . <(skaffold completion zsh)
#
function kubectl {
  unfunction "$0"
  source <(kubectl completion zsh)
  $0 "$@"
}

function helm() {
  unfunction "$0"
  source <(helm completion zsh)
  $0 "$@"
}

function stern() {
  unfunction "$0"
  source <(stern --completion zsh)
  $0 "$@"
}

function minikube() {
  unfunction "$0"
  source <(minikube completion zsh)
  $0 "$@"
}

function direnv(){
  unfunction "$0"
  source <(direnv hook zsh)
  $0 "$@"
}

function skaffold() {
  unfunction "$0"
  source <(skaffold completion zsh)
  $0 "$@"
}

function eksctl() {
  unfunction "$0"
  # source <(eksctl completion zsh)
  $0 "$@"
}

function istioctl() {
  unfunction "$0"
  source <(istioctl completion zsh)
  $0 "$@"
}
