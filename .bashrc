#Haobaopeng-Start
##############################################################
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export hbpScripts=~/.hbpScripts:/usr/local/bin/.hbpScripts
export RISCV_COMPILER=/packages/riscv/bin
export PATH=$hbpScripts:$RISCV_COMPILER:/opt/k8s/bin:$HOME/bin:$PATH
#export ARM_GCC_HOME=/usr/local/arm/4.4.3/bin
export ARM_GCC_HOME=/usr/local/arm/4.6.3/bin
export PATH=$PATH:$ARM_GCC_HOME
stty -ixon
alias svnst='svn status | grep \\b[AMD]\\s'

###java by haobaopeng
# export JAVA_HOME=/usr/lib/jvm/jdk1.6.0_23
# export ANDROID_JAVA_HOME=$JAVA_HOME
# export PATH=$JAVA_HOME:$PATH
##############################################################
#Haobaopeng-End


# Path to the bash it configuration
export BASH_IT="/home/qhu/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='pure'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Unomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
[[ -s /home/qhu/.autojump/etc/profile.d/autojump.sh ]] && source /home/qhu/.autojump/etc/profile.d/autojump.sh
source $BASH_IT/bash_it.sh
export SCM_GIT_SHOW_DETAILS=false
alias ls='ls --color'
alias ll='ls --color -l'

export TEST_TMPDIR=/home/qhu/enflame/prjs/cache
