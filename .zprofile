### Zsh options

# Expand the '!' character.
setopt BANG_HIST

# Save each command's beginning timestamp and duration.
setopt EXTENDED_HISTORY

# When a history expansion occurs, do not execute the command directly; reload
# the line instead.
setopt HIST_VERIFY

### Homebrew

eval "$(/opt/homebrew/bin/brew shellenv)"

### MacPorts

export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
