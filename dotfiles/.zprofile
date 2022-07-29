
EDITOR=nano
VISUAL=nano
LANG='en_US.UTF-8'; # Prefer US English
LC_ALL='en_US.UTF-8'; # Use UTF-8

export PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
export PATH="$HOME/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Check architecture and add correct Homebrew to PATH
case `arch` in
    arm64) # M1
        export BREW_PREFIX=/opt/homebrew
    ;;
    i386) # Intel
        export BREW_PREFIX=/usr/local
    ;;
esac
export PATH="$BREW_PREFIX/bin:$PATH"

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

neofetch
