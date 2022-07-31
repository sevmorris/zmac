alias l='exa -1a'                 # Lists in one column, hidden files.
alias ll='exa -l'                 # Lists human readable sizes.
alias lr='ll -R'                  # Lists human readable sizes, recursively.
alias la='ll -a'                  # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"'          # Lists human readable sizes, hidden files through pager.
alias lx='ll --sort=Extension'    # Lists sorted by extension (GNU only).
alias lk='ll --sort=size -r'      # Lists sorted by size, largest last.
alias lt='ll --sort=modified -r'  # Lists sorted by date, most recent last.
alias lc='lt -m'                  # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'                  # Lists sorted by date, most recent last, shows access time.
alias sl='ls'                     # I often screw this up.
alias c="clear && source ~/.zshrc"
alias cat="rich "
alias find="fd "
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"
alias mount="mount | column -t"
alias netcheck="networkQuality -v"
alias path='echo -e ${PATH//:/\\n}'
alias s="pmset displaysleepnow"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias sed="gsed"
#Create a Github remote repo from cd
alias gitready="git init -b main"
alias gitset='git add . && git commit -m "initial commit"'
alias gitgo="gh repo create"
# Homebrew aliases
alias brewup="brew -v update && brew -v upgrade && brew -v cleanup --prune=0 && brew doctor"
alias brun="brew uninstall -v "
alias brewfile="cd ~/.homebrew-brewfile && pushit && ~"
# alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Push current directory to Github
pushit() {
  DATE=$(date '+%y%m%d-%H%M')
  git pull 2>&1
  git add . 2>&1
  git commit -m "${DATE}" 2>&1
  git push 2>&1
}

# Open the current directory in Atom
at() {
  if [ $# -eq 0 ]; then
      atom .;
  else
      atom "$@";
  fi;
}

# tre :: `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Determine size of a file or total size of a directory
fs() {
  if du -b /dev/null > /dev/null 2>&1; then
      local arg=-sbh;
  else
      local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
      du $arg -- "$@";
  else
      du $arg .[^.]* *;
  fi;
}
