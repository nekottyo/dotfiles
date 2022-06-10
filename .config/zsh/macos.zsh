[[ -d /opt/homebrew/opt/grep/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/gnu-getopt/bin ]] && export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"
[[ -d /opt/homebrew/opt/gnu-sed/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/findutils/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/gnu-sed/libexec/gnubin ]]   && export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# set -x GPG_TTY=(tty)
export GPG_TTY=$(tty)
