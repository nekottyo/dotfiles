exists "gxargs" && alias xargs="gxargs"
exists "ggrep"  && alias grep="ggrep --color=auto"
exists "gsed"   && alias sed="gsed"
exists "gcut"   && alias cut="gcut"

set -x GPG_TTY (tty)
