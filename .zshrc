# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="evan"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias vz="vim ~/.zshrc"
alias sz="source ~/.zshrc"

alias du='du -h'

# Grep
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv,build,target}'
alias cgrep="grep -r -i -B 5 -A 5 "
alias rgrep='rg'

# Git
# alias ga='git add '
# alias gcmsg='git commit -m '
# alias gp='git push '
# alias gl='git pull '
# alias gst='git status '
# alias gd='git diff '
# alias gr='git restore '
# alias gco='git checkout '
# alias gb='git branch '
# alias gclean="git fetch --prune; git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D"

# AI CLI
alias updateclaude='claude update'
alias updategemini='npm install -g @google/gemini-cli@latest'
alias updatecodex='brew upgrade codex'

# alias ohmyzsh="mate ~/.oh-my-zsh" 

# `sudo passwd ubuntu` set password for the default ubuntu user
# `infocmp -x xterm-ghostty | ssh YOUR-SERVER -- tic -x -` copy Ghostty's terminfo to a remote machine
alias m='multipass '
alias mdefault='multipass launch -c 4 -m 4G -d 25G'

alias dots="~/Development/dotfiles/sync.sh"

# Bun
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"  # completions

# LLVM configuration - only uncomment if you need Homebrew LLVM for specific projects
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# Consolidated PATH configuration
export PATH="$BUN_INSTALL/bin:/opt/homebrew/bin:$HOME/.local/bin:/opt/homebrew/opt/libpq/bin:$HOME/go/bin:$PATH"

# Load environment variables from .env file
if [ -f ~/.env ]; then
  source ~/.env
fi

# screen session manager
s() {
      local session_name="${1:-main}"

      if screen -list | grep -q "$session_name"; then
          echo " Resuming session: $session_name"
          screen -r "$session_name"
      else
          echo " Starting new session: $session_name"
          screen -S "$session_name"
      fi
}

# manual flow
#   screen -S benchmark # start screen sessions
#   Press Ctrl+A, then D to detach
#   screen -r benchmark # reconnect later

alias sl='screen -ls'  # screen list

# screen kill - needs to be a function to accept arguments
sk() {
    if [ -z "$1" ]; then
        echo "Usage: sk <session_name>"
        return 1
    fi
    screen -S "$1" -X quit
}

alias dsstore='find . -name .DS_Store -delete' # deletes recursively

# prevents `malloc: nano zone abandoned due to inability to reserve vm space`
# in some debug builds
export MallocNanoZone=0

export CMAKE_BUILD_PARALLEL_LEVEL=$(($(sysctl -n hw.ncpu) - 2))
export EDITOR=vim 

rgs() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                                        Search: $@                                  "
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    rg "$@"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Added by Antigravity
export PATH="/Users/adamsoliev/.antigravity/antigravity/bin:$PATH"

alias brock="USE_RTTI=1 make static_lib -j$(nproc)"
alias crock="rm -rf /tmp/rocksdb*"
alias mexample="USE_RTTI=1 make modern_simple_example"
alias cexample="USE_RTTI=1 make compaction_example"

alias cheat='cat Development/cheatsheet'
