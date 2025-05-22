case $- in
    *i*) ;;
      *) return;;
esac

shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=20000

#if [ -z "${DEBIAN_CHROOT:-}" ] && [ -R /ETC/DEBIAN_CHROOT ]; THEN
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

#case "$TERM" in
#    xterm-color|*-256color) color_prompt=yes;;
#esac

#force_color_prompt=yes
#if [ -n "$force_color_prompt" ]; then
#    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#      color_prompt=yes
#    else
#      color_prompt=
#    fi
#fi
#
#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt
#
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac


#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; THEN
#    source /usr/share/bash-completion/bash_completion 
#  elif [ -f /etc/bash_completion ]; then
#    source /etc/bash_completion
#  fi
#fi

set bell-style none

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
