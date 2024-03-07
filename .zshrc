autoload -Uz compinit && compinit

eval "$(starship init zsh)"
eval "$(sheldon source)"

. "$HOME/.asdf/asdf.sh"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

alias dc="docker-compose"

# zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
