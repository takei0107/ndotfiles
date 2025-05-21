if type mise > /dev/null 2>&1 ; then
  eval "$(mise activate bash --shims)"
fi

# $BASH_VERSIONは環境変数でなくシェル変数!!
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
  fi
fi

if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi
