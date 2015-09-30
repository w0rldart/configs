##
# System
##
alias invoke-rc.d='sudo invoke-rc.d'
alias http-restart='invoke-rc.d nginx restart && invoke-rc.d php5-fpm restart'

alias aptitude='sudo aptitude'
alias apt-get='sudo apt-get'
alias uu='apt-get update && apt-get upgrade'

alias ls='ls --block-size=M'
alias rm='rm -i'
alias mv='mv -i'


##
# Custom stuff
##
alias webPerms='find  ./ -type d -exec chmod 755 {} \; && find ./ -type f -exec chmod 644 {} \;'
alias largestDirectories='du -hsx * | sort -rh | head -10'
alias composer="hhvm -v ResourceLimit.SocketDefaultTimeout=30 -v Http.SlowQueryThreshold=30000 /usr/local/bin/composer"
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


##
# Tools
##
# Add this to .bashrc or its equivalent
transfer() { if [ $# -eq 0 ]; then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; };
alias transfer=transfer
