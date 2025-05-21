if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

alias ll='ls -altr'

if check_bin "eza" ; then
  alias ee='eza --color=auto -lhg --sort=newest -ar'
fi
