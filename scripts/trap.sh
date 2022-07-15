#!/usr/bin/env zsh

set -e

# Some of this code was copy/pasted from Mike McQuaid's Strap repository
# https://github.com/MikeMcQuaid/strap

#. . . . . . . . . . . . . . . . _,,,--~~~~~~~~--,_
#. . . . . . . . . . . . . . ,-' : : : :::: :::: :: : : : : :º '-, ITS A TRAP!
#. . . . . . . . . . . . .,-' :: : : :::: :::: :::: :::: : : :o : '-,
#. . . . . . . . . . . ,-' :: ::: :: : : :: :::: :::: :: : : : : :O '-,
#. . . . . . . . . .,-' : :: :: :: :: :: : : : : : , : : :º :::: :::: ::';
#. . . . . . . . .,-' / / : :: :: :: :: : : :::: :::-, ;; ;; ;; ;; ;; ;; ;\
#. . . . . . . . /,-',' :: : : : : : : : : :: :: :: : '-, ;; ;; ;; ;; ;; ;;|
#. . . . . . . /,',-' :: :: :: :: :: :: :: : ::_,-~~,_'-, ;; ;; ;; ;; |
#. . . . . _/ :,' :/ :: :: :: : : :: :: _,-'/ : ,-';'-'''''~-, ;; ;; ;;,'
#. . . ,-' / : : : : : : ,-''' : : :,--'' :|| /,-'-'--'''__,''' \ ;; ;,-'/
#. . . \ :/,, : : : _,-' --,,_ : : \ :\ ||/ /,-'-'x### ::\ \ ;;/
#. . . . \/ /---'''' : \ #\ : :\ : : \ :\ \| | : (O##º : :/ /-''
#. . . . /,'____ : :\ '-#\ : \, : :\ :\ \ \ : '-,___,-',-`-,,
#. . . . ' ) : : : :''''--,,--,,,,,,¯ \ \ :: ::--,,_''-,,'''¯ :'- :'-,
#. . . . .) : : : : : : ,, : ''''~~~~' \ :: :: :: :'''''¯ :: ,-' :,/\
#. . . . .\,/ /|\\| | :/ / : : : : : : : ,'-, :: :: :: :: ::,--'' :,-' \ \
#. . . . .\\'|\\ \|/ '/ / :: :_--,, : , | )'; :: :: :: :,-'' : ,-' : : :\ \,
#. . . ./¯ :| \ |\ : |/\ :: ::----, :\/ :|/ :: :: ,-'' : :,-' : : : : : : ''-,,
#. . ..| : : :/ ''-(, :: :: :: '''''~,,,,,'' :: ,-'' : :,-' : : : : : : : : :,-'''\\
#. ,-' : : : | : : '') : : :¯''''~-,: : ,--''' : :,-'' : : : : : : : : : ,-' :¯'''''-,_ .
#./ : : : : :'-, :: | :: :: :: _,,-''''¯ : ,--'' : : : : : : : : : : : / : : : : : : :''-,
#/ : : : : : -, :¯'''''''''''¯ : : _,,-~'' : : : : : : : : : : : : : :| : : : : : : : : :
#: : : : : : : :¯''~~~~~~''' : : : : : : : : : : : : : : : : : : | : : : : : : : : :


bold=$(tput bold)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Just a bold yellow arrow
arrow() {
  echo "${yellow}${bold}>>> ${reset}$*"
}

STDIN_FILE_DESCRIPTOR="0"
[ -t "$STDIN_FILE_DESCRIPTOR" ] && TRAP_INTERACTIVE="1"

# We want to always prompt for sudo password at least once rather than doing
# root stuff unexpectedly
sudo --reset-timestamp

abort() {
  TRAP_STEP=""
  echo "!!! $*" >&2
  exit 1
}

# Set some basic security settings
arrow "Configuring security settings:"
sudo defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled \
  -bool false
sudo defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
  -bool false
sudo defaults write com.apple.screensaver askForPassword -int 1
sudo defaults write com.apple.screensaver askForPasswordDelay -int 0
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null

echo "OK"

# Install the Xcode Command Line Tools
if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
  arrow "Installing the Xcode Command Line Tools:"
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "$CLT_PLACEHOLDER"

  CLT_PACKAGE=$(softwareupdate -l \
    | grep -B 1 "Command Line Tools" \
    | awk -F"*" '/^ *\*/ {print $2}' \
    | sed -e 's/^ *Label: //' -e 's/^ *//' \
    | sort -V \
    | tail -n1)
  sudo softwareupdate -i "$CLT_PACKAGE"
  sudo rm -f "$CLT_PLACEHOLDER"
  if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    if [ -n "$TRAP_INTERACTIVE" ]; then
      echo
      arrow "Requesting user install of Xcode Command Line Tools:"
      xcode-select --install
    else
      echo
      abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
    fi
  fi
  echo "OK"
fi

# Check if the Xcode license is agreed to and agree if not
xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep $Q license; then
    if [ -n "$TRAP_INTERACTIVE" ]; then
      arrow "Asking for Xcode license confirmation:"
      sudo xcodebuild -license
      echo "OK"
    else
      abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  fi
}
xcode_license

# Download Homebrew
export GIT_DIR="$HOMEBREW_REPOSITORY/.git" GIT_WORK_TREE="$HOMEBREW_REPOSITORY"
git init $Q
git config remote.origin.url "https://github.com/Homebrew/brew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch $Q --tags --force
git reset $Q --hard origin/master
unset GIT_DIR GIT_WORK_TREE
echo "OK"

# Update Homebrew
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
arrow "Updating Homebrew:"
brew update --quiet
echo "OK"

# Install Homebrew Bundle, Cask and Services tap.
arrow "Installing Homebrew taps and extensions:"
brew bundle --quiet --file=- <<RUBY
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/services"
tap "homebrew/autoupdate"
tap "homebrew/bundle"
tap "homebrew/cask-drivers"
tap "homebrew/cask-fonts"
tap "homebrew/cask-versions"
tap "homebrew/command-not-found"
tap "bramstein/webfonttools"
tap "buo/cask-upgrade"
brew "ack"                                # Search tool like grep, but optimized for programmers
brew "adwaita-icon-theme"                 # Icons for the GNOME project
brew "asciiquarium"                       # Aquarium animation in ASCII art
brew "bash"                               # Bourne-Again SHell, a UNIX command interpreter (macOS's version of Bash is old)
brew "bash-completion@2"                  # Programmable completion for Bash 4.2+
brew "binutils"                           # GNU binary tools for native development
brew "cask"                               # Emacs dependency management
brew "cmake"                              # Cross-platform make
brew "coreutils"                          # GNU File, Shell, and Text utilities
brew "cowsay"                             # Configurable talking characters in ASCII art
brew "curl"                               # Get a file from an HTTP, HTTPS or FTP server
brew "diffutils"                          # File comparison utilities
brew "duf"                                # Disk Usage/Free Utility - a better 'df' alternative
brew "exa"                                # Modern replacement for 'ls'
brew "fd"                                 # Simple, fast and user-friendly alternative to find
brew "findutils"                          # Collection of GNU find, xargs, and locate
brew "fortune"                            # Infamous electronic fortune-cookie generator
brew "gawk"                               # GNU awk utility
brew "gh"                                 # GitHub command-line tool
brew "git-extras"                         # Small git utilities
brew "gitmoji"                            # Interactive command-line tool for using emoji in commit messages
brew "glances"                            # Utility to provide quick look previews for files that aren't natively supported
brew "glib"                               # Core application library for C
brew "gnu-indent"                         # C code prettifier
brew "gnu-sed"                            # GNU implementation of the famous stream editor
brew "gnu-tar"                            # GNU version of the tar archiving utility
brew "gnu-which"                          # GNU implementation of which utility
brew "grep"                               # GNU grep, egrep and fgrep
brew "gtop"								                # System monitoring dashboard for terminal
brew "gzip"                               # Popular GNU data compression program
brew "harfbuzz"                           # OpenType text shaping engine
brew "htop"                               # Improved top (interactive process viewer)
brew "iftop"                              # Display an interface's bandwidth usage
brew "legit"                              # Command-line interface for Git, optimized for workflow simplicity
brew "less"                               # Pager program similar to more
brew "libconfig"                          # Configuration file processing library
brew "lolcat"                             # Rainbows and unicorns in your console!
brew "lua"                                # Powerful, lightweight programming language
brew "lynis"                              # Security and system auditing tool to harden systems
brew "make"                               # Utility for directing compilation
brew "mas"                                # Mac App Store command-line interface
brew "moreutils"                          # Collection of tools that nobody wrote when UNIX was young
brew "most"                               # Powerful paging program
brew "nano"                               # Free (GNU) replacement for the Pico text editor
brew "ncdu"                               # NCurses Disk Usage
brew "neofetch"                           # Fast, highly customisable system info script
brew "nghttp2"                            # HTTP/2 C Library
brew "nmap"                               # Port scanning utility for large networks
brew "node"                               # Platform built on V8 to build network applications
brew "openssl@3"                          # Also known as: openssl. Cryptography and SSL/TLS Toolkit
brew "pango"                              # Framework for layout and rendering of i18n text
brew "pcre2"                              # Perl compatible regular expressions library with a new API
brew "php", restart_service: true         # General-purpose scripting language
brew "pinentry-mac"                       # Pinentry for GPG on Mac
brew "rich"                               # Command line toolbox for fancy output in the terminal
brew "rsync"                              # Utility that provides fast incremental file transfer
brew "screen"                             # Terminal multiplexer with VT100/ANSI terminal emulation
brew "shellcheck"                         # Static analysis and lint tool, for (ba)sh scripts
brew "sl"                                 # Prints a steam locomotive if you type sl instead of ls
brew "smartmontools"                      # SMART hard drive monitoring
brew "speedtest-cli"                      # Command-line interface for https://speedtest.net bandwidth tests
brew "tldr"                               # Simplified and community-driven man pages
brew "topgrade"                           # Detects which tools you use and runs the appropriate commands to update them
brew "tree"                               # Display directories as trees (with optional color/HTML output)
brew "vim"                                # Vi 'workalike' with many additional features
brew "watch"                              # Executes a program periodically, showing output fullscreen
brew "watchman"                           # Watch files and take action when they change
brew "wdiff"                              # Display word differences between text files
brew "wget"                               # Internet file retriever
brew "zsh"
brew "bramstein/webfonttools/sfnt2woff"
brew "bramstein/webfonttools/sfnt2woff-zopfli"
RUBY
echo "OK"

# Using GNU command line tools in macOS instead of FreeBSD tools
# https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da
BREW_BIN="/usr/local/bin/brew"
if [ -f "/opt/homebrew/bin/brew" ]; then
    BREW_BIN="/opt/homebrew/bin/brew"
fi

if type "${BREW_BIN}" &> /dev/null; then
    export BREW_PREFIX="$("${BREW_BIN}" --prefix)"
    for bindir in "${BREW_PREFIX}/opt/"*"/libexec/gnubin"; do export PATH=$bindir:$PATH; done
    for bindir in "${BREW_PREFIX}/opt/"*"/bin"; do export PATH=$bindir:$PATH; done
    for mandir in "${BREW_PREFIX}/opt/"*"/libexec/gnuman"; do export MANPATH=$mandir:$MANPATH; done
    for mandir in "${BREW_PREFIX}/opt/"*"/share/man/man1"; do export MANPATH=$mandir:$MANPATH; done
fi

# Check and install any remaining software updates
arrow "Checking for software updates:"
  sudo softwareupdate --install --all
  xcode_license
fi

echo "OK"
