alias uu='apt-get update && apt-get upgrade'

# Override default behaviour
alias ls='ls --block-size=M --color'
alias rm='rm -i'
alias mv='mv -i'


##
# Custom stuff
##
alias webPerms='find  ./ -type d -exec chmod 755 {} \; && find ./ -type f -exec chmod 644 {} \;'
alias t-apache-error='tail -f /var/log/apache2/error.log'
alias t-nginx-error='tail -f /var/log/nginx/error.log'


##
# Git aliases
##
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'