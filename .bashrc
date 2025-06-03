case $- in
    *i*) ;;
      *) return;;
esac

shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=20000

check_bin() {
  type "$1" > /dev/null 2>&1
}

setup_mise() {
  if check_bin "mise" ; then
    # activate mise
    eval "$(mise activate bash)"

    #
    # bash-completionのバージョンが2.12以上でないとエラーが出てしまうためコメントアウトしている。
    # このサイトからバージョンが照合できる。:
    #   https://repology.org/project/bash-completion/versions
    #
    # mise completion
    #local compdir="/etc/bash_completion.d"
    #if [[ ! -d "$compdir" ]] ; then
    #  echo "(require root) make directory: $compdir"
    #  sudo mkdir -p "$compdir"
    #fi
    #local completion="$compdir"/mise
    #if [[ ! -f "$completion" ]] ; then
    #  if ! type usage > /dev/null 2>&1 ; then
    #    mise use -g usage
    #  fi
    #  echo "(require root) make file: $completion"
    #  mise completion bash | sudo tee "$completion" > /dev/null && source "$completion"
    #fi

  fi
}

setup_zoxide() {
  if check_bin "zoxide" ; then
    eval "$(zoxide init bash)"
  fi
}

setup_starship() {
  if check_bin "starship" ; then
    eval "$(starship init bash)"
  fi
}

setup_mise
setup_zoxide
setup_starship

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# disable bash-completion
complete -r
