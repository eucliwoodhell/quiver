CARGO_DIR="$HOME/.cargo/bin"
# JENV_DIR="$HOME/.jenv/bin"
# JAVA_HOME="/opt/homebrew/opt/openjdk/bin"
# LIBPQ_DIR="/opt/homebrew/opt/libpq/bin"
# FLUTER_DIR="$HOME/develop/flutter/bin"
LSD_DIR="$HOME/.config/lsd"
LOCAL_BIN="$HOME/.local/bin"

# colima
alias colima-start='colima start --network-address'

# if is macos
if [[ "$OSTYPE" == "darwin"* ]]; then
  export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"
  export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address')
  # export TESTCONTAINERS_HOST_OVERRIDE="127.0.0.1"
fi

#end

# lsd
alias ls='lsd -l'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
# end

# git
alias s='git status -sb'
alias ga='git add -A'
alias gap='ga -p'
alias gbr='git branch -v'
alias gch='git cherry-pick'
alias gcm='git commit -v --amend'
alias gco='git checkout'
alias gd='git diff -M'
alias gd.='git diff -M --color-words="."'
alias gdc='git diff --cached -M'
alias gdc.='git diff --cached -M --color-words="."'
alias gf='git fetch'
alias glog='git log --date-order --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset"'
alias gl='glog --graph'
alias gla='gl --all'
alias gm='git merge --no-ff'
alias gmf='git merge --ff-only'
alias gp='git push'
alias grb='git rebase -p'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias gr='git reset'
alias grh='git reset --hard'
alias grsh='git reset --soft HEAD~'
alias grv='git remote -v'
alias gs='git show'
alias gs.='git show --color-words="."'
alias gst='git stash'
alias gstp='git stash pop'
alias gup='git pull'
# end

# zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-completions
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [ -f /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
elif [ -f /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

# powerlevel10k
if [ -f /usr/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme ]; then
  source /usr/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f /opt/homebrew/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme ]; then
  source /opt/homebrew/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f /usr/local/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme ]; then
  source /usr/local/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export PATH="$CARGO_DIR:$LSD_DIR:$LOCAL_BIN:$PATH"
