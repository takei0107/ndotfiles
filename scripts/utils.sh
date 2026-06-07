_log_prefix() {
  if [[ -v SCRIPT_DIR ]] && [[ -v SCRIPT_NAME ]]; then
    echo -n "[$SCRIPT_DIR/$SCRIPT_NAME] "
  fi
}

log_info() {
  _log_prefix
  echo "$@"
}

log_error() {
  _log_prefix
  echo "$@" 1>&2
}

log_fatal() {
  log_error "$@"
  exit 1
}

print_distro() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "$NAME"
  elif command -v lsb_release >/dev/null 2>&1; then
    lsb_release -si
  elif [ -r /etc/issue ]; then
    head -n 1 /etc/issue
  else
    uname -s
  fi
}

check_executable() {
  if [ $# -ne 1 ]; then
    log_fatal "required 1 args(exe file name)"
  fi

  type "$1" > /dev/null 2>&1
}
