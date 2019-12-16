eval "$(anyenv init - --no-rehash)"

# go
export GO111MODULE=auto
export GOPATH=${HOME}/.golang
export GOROOT=$( go env GOROOT )
export PATH=${GOPATH}/bin:$(go env GOPATH)/bin:${PATH}

exists "npm" && export PATH=${PATH}:$(npm bin):$(npm -g  bin)
