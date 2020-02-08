if [[ "${TMUX}" != "" ]] ; then
  TMUX_LOG_PATH="${HOME}/.logs/tmux"
  if [[ ! -d "${TMUX_LOG_PATH}" ]]; then
    mkdir -p "${TMUX_LOG_PATH}"
  fi
  tmux pipe-pane "cat | rotatelogs ${TMUX_LOG_PATH}/%Y%m%d_%H-%M-%S_#S:#I.#P.log 86400 540"
fi
