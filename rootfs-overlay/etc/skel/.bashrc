# BOLT OS interactive Bash defaults.
case $- in *i*) ;; *) return ;; esac
# Konsole can start a non-login shell; ensure system tools are visible.
for bolt_dir in /usr/local/sbin /usr/local/bin /usr/bin; do
  case ":${PATH:-}:" in
    *":$bolt_dir:"*) ;;
    *) PATH="$bolt_dir${PATH:+:$PATH}" ;;
  esac
done
export PATH
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend checkwinsize
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[1;33m\]bolt\[\e[0m\] \u@\h:\w\$ '
unset bolt_dir
