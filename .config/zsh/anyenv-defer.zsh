# go
# export GOPATH=${HOME}/.golang
# export GOROOT=$(go env GOROOT )
# export PATH=${GOPATH}/bin:$(go env GOPATH)/bin:${PATH}

source ~/.config/zsh/functions/exists

# https://zenn.dev/ktakayama/articles/27b9d6218ed2f0ee9992
if exists "anyenv"
then
   if ! [ -f /tmp/anyenv.cache ]; then
      anyenv init - --no-rehash > /tmp/anyenv.cache
      zcompile /tmp/anyenv.cache
   fi
   source /tmp/anyenv.cache

   if ! [ -f /tmp/nodeenv.cache ]; then
      nodenv init - > /tmp/nodeenv.cache
      zcompile /tmp/nodeenv.cache
   fi
   source /tmp/nodeenv.cache
fi

exists "npm" && export PATH=${PATH}:$(npm bin):$(npm -g  bin)
