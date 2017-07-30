#!/bin/bas

find . -type d -name '.git' -prune -o -name 'tmux-powerline' -prune -o -type d -print \

#find . -type d -name '.git' -prune -o -name 'tmux-powerline' -prune -o -type f -print \
#    | grep -E -v "(README.md|bootstrap.sh|.gitmodules)"
