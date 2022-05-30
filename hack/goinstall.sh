#!/bin/bash

function list_package() {
  local gobin="$(go env GOBIN)"
  local gobin="${gobin:-$(go env GOPATH)/bin}"

  gfind "${gobin}" -type f | while read pkg; do
    local pkg_version="$(go version -m "${pkg}" | head -n2 | tail -1 | awk '{print $2}')"
    echo ${pkg_version}
  done
}

function show_package() {
  list_package | xargs -n1 -I{} echo "{}@latest"
}


pushd ~ > /dev/null
if [[ "$@" == "list" ]]; then
  list_package
fi
if [[ "$@" == "show" ]]; then
  show_package
fi
popd > /dev/null
