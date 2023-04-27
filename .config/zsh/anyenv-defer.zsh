# go
# export GOPATH=${HOME}/.golang
# export GOROOT=$(go env GOROOT )
# export PATH=${GOPATH}/bin:$(go env GOPATH)/bin:${PATH}

exists "npm" && export PATH=${PATH}:$(npm bin):$(npm -g  bin)

eval "$(anyenv init --no-rehash -)"
