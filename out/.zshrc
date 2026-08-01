if [[ ("$TERM_PROGRAM" == "WezTerm") && -z "$(tmux list-clients 2>/dev/null)" ]]; then
    exec tmux new -As main;
fi

export LANG="en_US.UTF-8"

PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '

alias brewup="brew update && brew upgrade && brew doctor"

export BREW="/opt/homebrew"
eval "$("$BREW/bin/brew" shellenv)"

export LIBRARY_PATH="$LIBRARY_PATH:$BREW/lib/gcc/current"
export LDFLAGS="-L$BREW/lib"
export CPPFLAGS="-I$BREW/include"

alias g="git"
alias l="ls -lah"
alias kubens="kubectl config set-context --current --namespace "

export PATH="/Users/kimsaram32/me/ws/bin:$PATH"

eval "$(mise activate zsh)"
export PATH=$PATH:$HOME/zk/bin

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

export FZF_DEFAULT_OPTS=" \
  --preview 'bat --color=always {}' --preview-window up \
  --bind \"ctrl-y:execute-silent(basename {} | cut -d . -f1 | tr -d '\n' | pbcopy)\" \
  --bind \"ctrl-o:execute-silent[ \
    tmux select-pane -R
    tmux send-keys :e Space && \
    tmux send-keys -l {} && \
    tmux send-keys Enter \
  ]\""

fif () {
  if [ ! "$#" -gt 0 ]
  then
    echo "Need a string to search for!"
    return 1
  fi
  rg --files-with-matches --no-messages -i "$1" $PWD | \
  fzf --delimiter / --with-nth -1 \
    --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

export LDFLAGS="-L/opt/homebrew/opt/tree-sitter@0.25/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/tree-sitter@0.25/include $CPPFLAGS"

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/opt/tree-sitter@0.25/lib/pkgconfig"

export RESTIC_REPOSITORY=/Volumes/What/backups
export RESTIC_PASSWORD_FILE=~/.restic_password

export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

export PNPM_HOME="/Users/kimsaram32/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

alias yarn="corepack yarn"
alias yarnpkg="corepack yarnpkg"
alias pnpm="corepack pnpm"
alias pnpx="corepack pnpx"
alias npm="corepack npm"
alias npx="corepack npx"

export PATH="/Users/kimsaram32/.deno/bin:$PATH"

export PATH="$HOME/.local/bin/:$PATH"

export GOPATH="/Users/kimsaram32/go"
export PATH="$GOPATH/bin:$PATH"

export PATH="/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kimsaram32/.local/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kimsaram32/.local/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kimsaram32/.local/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kimsaram32/.local/google-cloud-sdk/completion.zsh.inc'; fi

__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

export PATH="/Users/kimsaram32/.antigravity/antigravity/bin:$PATH"

# https://github.com/keybase/keybase-issues/issues/2798
export GPG_TTY=$(tty)

xqns () {
    kubectl config set-context --current --namespace "$1-dsm-project"
}

xqgrafana () {
    local secret=$(kubectl get secret grafana-admin-password -oyaml | grep -- "password:" | awk '{print $2}' | base64 -d)
    pbcopy <<< $secret
    echo $secret
}
