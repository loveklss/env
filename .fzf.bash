# Setup fzf
# ---------
if [[ ! "$PATH" == */home/qhu/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/qhu/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/qhu/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/qhu/.fzf/shell/key-bindings.bash"
