# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
# https://www.reddit.com/r/zsh/comments/5ogkbt/fzf_help/
fstash() {
  emulate -L sh
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    out=( "${(@f)out}" )
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}


# cd to repository managed by ghq
fghq() {
  local ghq_root=$(ghq root)
  local repo=$(ghq list | fzf)
  if [[ -z "$repo" ]]; then
    zle accept-line
    return
  fi
  BUFFER="cd ${ghq_root}/${repo}"
  zle accept-line
}
zle -N fghq
bindkey '^g' fghq

# search recently used directory with fzf
fzf-z-search() {
  local res=$(z | sort -rn | cut -c 12- | fzf)
  if [ -n "$res" ]; then
      BUFFER+="cd $res"
      zle accept-line
  else
      return 1
  fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search
bindkey '^[f' fzf-z-search


if exists "lsec2"; then
  # ssh to ec2 instance
  lssh() {
    IP=$(lsec2 $@ | fzf | awk -F "\t" '{print $2}')
    if [[ $? == 0 && "${IP}" != "" ]]; then
        echo ">>> SSH to ${IP}"
        ssh ${IP}
    fi
  }

  # ssh to multiple sc2 instances
  xssh() {
    IPS=$(lsec2 | fzf -m | awk -F "\t" '{print $2}')
    if [[ $? == 0 && "${IPS}" != "" ]]; then
      echo "$IPS" | xpanes -t -c 'ssh {}'
    fi
  }
fi

# set context and switch namespace
eks-write-config() {
  local cluster=$(eksctl get cluster | fzf | awk '{print $1}')
  if [[ $cluster != '' ]]; then
    eksctl utils write-kubeconfig --name "${cluster}"
    exists "kubens" && kubens
  fi
}

# find current files and edit selected file
fdv () {
  local file=$(fd | fzf)
  if [[ "${file}" != '' ]]; then
    ${EDITOR} ${file}
  fi
}

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
