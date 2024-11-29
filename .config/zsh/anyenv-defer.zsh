# go

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

  if ! [ -f /tmp/goenv.cache ]; then
    goenv init - > /tmp/goenv.cache
    zcompile /tmp/goenv.cache
  fi

  export GOROOT="$(go env GOROOT)"
  export GOBIN="${GOROOT}/bin"
  export PATH="$(go env GOBIN):${PATH}"
  source /tmp/goenv.cache
fi

exists "npm" && export PATH=${PATH}:$(npm prefix /bin):$(npm prefix -g /bin)
