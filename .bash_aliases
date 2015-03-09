alias invoke-rc.d='sudo invoke-rc.d'

alias webPerms='find  ./ -type d -exec chmod 755 {} \; && find ./ -type f -exec chmod 644 {} \;'

alias apt-get='sudo apt-get'
alias uu='sudo apt-get update && sudo apt-get upgrade'

alias http-restart='invoke-rc.d nginx restart && invoke-rc.d php5-fpm restart'
