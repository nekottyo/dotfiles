#!/bin/zsh

# require gh auth login

gh gist view 8612dc12ca90af0a55a2d48023dd3c72 -f .saml2aws > ~/.saml2aws

mkdir ~/.aws
gh gist view 8612dc12ca90af0a55a2d48023dd3c72 -f .aws_config > ~/.aws/config

gh gist view 7cad47efad2c0e48b9dce13e6911847d -f .gitconfig.local > ~/.gitconfig.local

gh gist view 7cad47efad2c0e48b9dce13e6911847d -f .zshrc.local > ~/.zshrc.local

gh gist view 33c2787207e542b317ce9b11273b765c -f gistfile1.txt > ~/.gitconfig

mkdir  ~/.ssh
gh gist view 684c209f3c8df67259ce0c883bd5b6cd -f ssh_config > ~/.ssh/config
