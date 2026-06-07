#!/usr/bin/env bash

set -e
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/../utils.sh"

NEOVIM_REPO_NAME="neovim/neovim"

WORK_DIR=

_install_prerequisites_debian() {
  sudo apt install --no-install-recommends \
    ninja-build \
    gettext \
    cmake \
    curl \
    build-essential \
    git
}

install_prerequisites() {
  local distro=$(print_distro)

  log_info "install prerequisites for $distro"

  case ${distro} in
    Ubuntu|Debian)
      _install_prerequisites_debian ;;
    *)
      echo "case of $distro is not defined" 1>&2
      return 1 ;;
  esac
}

_check_git_isexecutable() {
  if ! check_executable git ; then
    log_fatal "git is not installed" 
  fi
}

_check_ghq_isexecutable() {
  if ! check_executable ghq ; then
    log_fatal "ghq is not installed" 
  fi
}

download_with_git_clone() {
  _check_git_isexecutable

  local dir="/tmp/neovim-$(date +'%Y%m%d%H%M%S')"
  local cmd="git clone https://github.com/$NEOVIM_REPO_NAME $dir"

  log_info "exec git clone"

  eval $cmd

  WORK_DIR="$dir"
}

print_ghq_repo_path() {
  _check_ghq_isexecutable
  ghq list --full-path "$NEOVIM_REPO_NAME"
}

download_with_ghq() {
  _check_ghq_isexecutable

  local ghq_path=$(print_ghq_repo_path)

  if [ -z "$ghq_path" ] ; then
    ghq clone "https://github.com/$NEOVIM_REPO_NAME"
    ghq_path=$(print_ghq_repo_path)
    if [ -z "$ghq_path" ] ; then
      log_fatal "local path for neovim repo has not retrived"
    fi
  else
    (cd "$ghq_path" && git pull)
  fi

  WORK_DIR="$ghq_path"
}

download_source() {
  local download_fn=download_with_git_clone
  local info_prefix="download neovim source by "
  local method="git clone"
  if check_executable ghq ; then
    download_fn=download_with_ghq
    method="ghq"
  fi

  log_info "$info_prefix$method"
  eval "$download_fn"
}

_build_neovim() {
  log_info "start building"
  make CMAKE_BUILD_TYPE=RelWithDebInfo
}

_install_neovim() {
  log_info "start install"
  sudo make install
}

build_from_source() {
  if [ -z "$WORK_DIR" ]; then
    log_fatal "$WORK_DIR is empty"
  fi

  log_info "build:work in $WORK_DIR"
  cd $WORK_DIR && pwd && _build_neovim
}

install() {
  log_info "installing neovim start"
  if [ -z "$WORK_DIR" ]; then
    log_fatal "$WORK_DIR is empty"
  fi

  log_info "install:work in $WORK_DIR"
  cd $WORK_DIR && pwd && _install_neovim
  log_info "installing neovim finished"
}

build() {
  log_info "building neovim start"
  install_prerequisites
  download_source
  build_from_source
  log_info "building neovim finished"
}

main() {
  log_info "start"
  build
  install
  log_info "finished"
}

main
