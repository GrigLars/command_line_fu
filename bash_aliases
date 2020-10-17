# Some of my own aliases, or aliases someone had given me that seemed clever at the time

alias ..='cd ..'
alias :wq="exit"
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias apt-get='sudo apt-get'
alias dfh='df -hT -xtmpfs -xdevtmpfs | grep -v loop'
alias fuck='kill -9 $1'
alias gcm="git commit -m"
alias hgrep='history | grep'
alias l='ls -CF'
alias la='ls -A'
alias lh='ls -halt'
alias lht='ls --human-readable --size -1 -S --classify'
alias ll='ls -alF'
alias please='sudo !!'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
# reload shell without exit
alias reload="exec $SHELL -l"
alias stashrebase='git stash save && git fetch && git rebase origin master && git stash apply'
# Some Vagrant-related stuff
alias vagpro="vagrant provision"
alias vagredo="vagrant destroy -f && vagrant up"
alias vagrm="vagrant destroy -f"
alias vagssh="vagrant ssh"
alias vagstat="vagrant global-status"
alias vagtrim="vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done && vagrant box prune -f"
alias vagupdate="vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done"
alias vagwho="vagrant global-status"
alias vgdn="vagrant halt"
alias vgdown="vagrant halt"
alias vgssh="vagrant ssh"
alias vgup="vagrant up"
# Close shell keeping all subprocess running
alias close-but-disown="disown -a && exit"
# Reset all git changes back to old
alias grhlc='AAA=$(git log|head -1|cut -d" " -f2); git reset --hard $AAA'
# Get weather info
alias weather='curl wttr.in'
# Remove trailing whitespace
alias del_ws="sed -i 's/\s*$//g'"
alias sys_active='sudo systemctl --type=service --state=active'
alias sys_run='sudo systemctl --type=service --state=running'
