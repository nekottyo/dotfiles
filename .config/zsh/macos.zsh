[[ -d /opt/homebrew/opt/grep/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/gnu-getopt/bin ]] && export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"
[[ -d /opt/homebrew/opt/gnu-sed/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/findutils/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/gnu-sed/libexec/gnubin ]]   && export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
[[ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]] && export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
# Claude Code は環境表示が darwin なので BSD 形の `sed -i ''` を書く。agent の shell でだけ shim で受ける (~/.agents ADR-245)
[[ -n $CLAUDECODE && -d $HOME/.agents/scripts/shims ]] && export PATH="$HOME/.agents/scripts/shims:$PATH"

# set -x GPG_TTY=(tty)
export GPG_TTY=$(tty)
