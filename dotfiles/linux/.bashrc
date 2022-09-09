source ~/.git-prompt.sh
source ~/.git-completion.sh

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;35m\]$(__git_ps1)\[\033[00m\]\$ '

if [ -f ~/.linux_aliases ]; then
    . ~/.linux_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
