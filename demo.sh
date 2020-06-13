#!/usr/bin/env bash
set -eo pipefail

# determine the root of the repo or path the demo script is run from if not a git repo
REPO="$(git rev-parse --show-toplevel 2>/dev/null)" || REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# tools list
declare -A TOOLS
# shellcheck disable=SC2016
TOOLS[skaffold]='https://storage.googleapis.com/skaffold/releases/v1.10.1/skaffold-${OS}-amd64'
# shellcheck disable=SC2016
TOOLS[kubectl]='https://storage.googleapis.com/kubernetes-release/release/v1.15.11/bin/${OS}/amd64/kubectl'
# shellcheck disable=SC2016
TOOLS[kind]='https://github.com/kubernetes-sigs/kind/releases/download/v0.8.1/kind-${OS}-amd64'

# deploy the resources to the cluster
deploy() {
  cd "${REPO}"/cluster/nginx/ && skaffold run --status-check=false
  cd "${REPO}"/cluster/prometheus/ && skaffold run --status-check=false
  cd "${REPO}"/app/ && skaffold run --status-check=false
}

# start the kind cluster
up() {
  kind create cluster --name "demo" --image "kindest/node:v1.15.11" --config "cluster/kind/config/config.yaml" --verbosity="0"
  kubectl apply -f "${REPO}"/cluster/namespaces.yaml
  deploy
}

# stop the kind cluster
down() {
  kind delete cluster --name "demo" --verbosity="0"
}

# Download a file from tools
_download() {
  local name=${1}
  local url
  url=$(eval "echo ${TOOLS["${name}"]}")
  curl -sLo "${REPO}/bin/${name}" "${url}"
  chmod +x "${REPO}/bin/${name}"
}

#setup required binaries
_setup() {
  for cmd in kind kubectl skaffold ; do
    if ! command ${cmd} >/dev/null 2>&1; then
      mkdir -p "${REPO}/bin"
      printf "%s not found, downloading" "${cmd}"
      _download "${cmd}"
    fi
  done
}

# determine if the OS is linux or mac
_os() {
  local os
  case "$(uname -s)" in
    Darwin*) 
      os=darwin
      ;;
    Linux*) 
      os=linux 
      ;;
    *) 
      os=unk 
      ;;
  esac
  echo "${os}"
}
# shellcheck disable=SC2034
OS=$(_os)

#run setup
_setup

# check if docker is running
if ! docker ps >/dev/null 2>&1; then
  printf "Error: cannot connect to docker"
  exit 1
fi

# if bin exists, include it because we had missing deps.
if [[ -d "${REPO}/bin" ]]; then
  export PATH="${REPO}/bin:$PATH"
fi


# check if they provided input
if [[ -n "${1}" ]]; then
  IFS=$'\n' # make newlines the only separator
  set -f    # disable globbing
  found=0
  # find all functions and determine a match 
  for f in $(declare -F); do
    if [[ ${f:11} == "${1}" ]]; then
      found=$((found+1))
    fi
  done
  # if not match is found, then exit
  if [[ ${found} -eq 0 ]];then
    printf "Error: '%s' is not a valid option" "${1}"
    exit 1
  fi
  eval "$@"
else
  printf "Error: no option passed"; exit 1
fi
