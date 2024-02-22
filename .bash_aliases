alias hg='history|grep'
## Use a long listing format ##
alias ll='ls -la'
## get rid of command not found ##
alias cd..='cd ..'

## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
# handy short cuts #
alias h='history'
alias c='clear'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
# update on one command
alias update='sudo apt-get update && sudo apt-get upgrade'
alias su='sudo -i'
alias grep='grep --color=auto'
alias df='df -h'
alias reload='source ~/.bashrc'
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias tree='tree -C --dirsfirst'
alias process='ps aux'
alias extract='for i in *.gz; do tar xvf $i; done'
alias du1='du -h -d 1' 
alias weather='function _weather() { curl wttr.in/$1; }; _weather'
