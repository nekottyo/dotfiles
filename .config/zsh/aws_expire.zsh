function aws_expire() {
  TARGET_PROFILE=${AWS_PROFILE:-default}
  TARGET_FILE=${AWS_CREDENTIALS_FILE:-~/.aws/credentials}
  STYLE="bold yellow"

  expire=$(grep "${TARGET_PROFILE}" -A6 "${TARGET_FILE}" \
    | tail -1 \
    | awk '{print $3}' \
    | gdate +%s -d -)
  now=$(date +%s)
  if [[ "${now}" < "${expire}" ]]; then
    echo_yellow "credential expired"
  fi
}

function echo_yellow() {
  echo -e "☁️ \033[33m${1}\033[0m"
}
