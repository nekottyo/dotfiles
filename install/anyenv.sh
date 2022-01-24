#!/bin/zsh
#

mkdir -p $(anyenv root)/plugins
git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update


anyenv install --init

for e in goenv rbenv nodenv tfenv pyenv; do
  anyenv install "${e}"
done

anyenv update

eval "$(anyenv init -)"


GO_VERSION=1.17.3
goenv install ${GO_VERSION}
goenv global ${GO_VERSION}



git clone https://github.com/rbenv/rbenv-default-gems.git $(rbenv root)/plugins/rbenv-default-gems
cat <<EOF > $(rbenv root)/default-gems
neovim
solargraph
EOF
RUBY_VERSION=2.7.5
rbenv install ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}


git clone https://github.com/jawshooah/pyenv-default-packages.git $(pyenv root)/plugins/pyenv-default-packages
cat <<EOF > $(pyenv root)/default-packages
pynvim
EOF
PYTHON_VERSION=3.10.0
pyenv install ${PYTHON_VERSION}
pyenv global ${PYTHON_VERSION}


git clone https://github.com/nodenv/nodenv-default-packages.git $(nodenv root)/plugins/nodenv-default-packages
cat <<EOF > $(nodenv root)/default-packages
neovim
EOF
NODE_VERSION=16.13.1
nodenv install ${NODE_VERSION}
nodenv global ${NODe_VERSION}
