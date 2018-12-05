# Some of my own aliases

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -halt'
alias psgrep=r'ps aux | grep -v grep | grep -i -e VSZ -e'
alias fuck='kill -9 $1'
alias please='sudo !!'
alias :wq="exit"
alias vagpro="vagrant provision"
alias vagredo="vagrant destroy -f && vagrant up"
alias vagwho="vagrant global-status"
alias vagstat="vagrant global-status"
alias vagssh="vagrant ssh"
alias vagrm="vagrant destroy -f"
alias vgup="vagrant up"
alias vgdown="vagrant halt"
alias vgdn="vagrant halt"
alias vgssh="vagrant ssh"
