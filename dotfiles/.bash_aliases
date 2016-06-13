##
# System
##
alias invoke-rc.d='sudo invoke-rc.d'

# Debian/Ubuntu
alias aptitude='sudo aptitude'
alias apt-get='sudo apt-get'
alias uu='apt-get update && apt-get upgrade'

# CentOS
alias yum='sudo yum'

# Override default behaviour
alias ls='ls --block-size=M --color'
alias rm='rm -i'
alias mv='mv -i'


##
# Custom stuff
##
alias webPerms='find  ./ -type d -exec chmod 755 {} \; && find ./ -type f -exec chmod 644 {} \;'
alias largestDirectories='du -hsx * | sort -rh | head -10'
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

update-repos() {
  for dir in `ls`; do CURRENT_PATH=`pwd`; DIR_PATH=$CURRENT_PATH/$dir; cd $DIR_PATH; git pull; cd ../ ; done
}
alias update-repos=update-repos
