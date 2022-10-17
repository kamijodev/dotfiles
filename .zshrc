# homebrew path
export PATH=/opt/homebrew/bin:$PATH
# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh
# zinit
source /opt/homebrew/opt/zinit/zinit.zsh
# starship
eval "$(starship init zsh)"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

setopt inc_append_history
setopt share_history

alias s=source
alias v=nvim
alias vi=nvim
alias vim=nvim
alias work='cd ~/Work'
alias ls='exa --icons'
alias la='exa --icons -a'
alias ~='cd ~'
