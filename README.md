

## Step 1

Install Homebrew
<br>

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


## Step 2

Install oh-my-zsh
<br>

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```


Install oh-my-zsh plugins
<br>

```
cd ~/.oh-my-zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```


## Step 3

Clone zmac and run install script
<br>

```
cd ~
eval $(/opt/homebrew/bin/brew shellenv)
git clone https://github.com/sevmorris/zmac.git && cd zmac && chmod +x install
./install
cd ~
```


## Step 4

Switch to Homebrew's Zsh
<br>

M1
```
sudo -i
echo /opt/homebrew/bin/zsh >> /etc/shells
exit
chsh -s /opt/homebrew/bin/zsh
```

<br>

Intel
```
sudo -i
echo /usr/local/bin/zsh >> /etc/shells
exit
chsh -s /usr/local/bin/zsh
```


## Step 5

Clean up (optional)
<br>

```
rm -r $HOME/zmac
```

:warning:  Restart the terminal or open a new tab


Try out some new commands to clean up/update Homebrew & packages

```
brewup
topgrade
```

## Step X

To remove all Dock icons, such as after a fresh OS install
<br>

```
defaults write com.apple.dock persistent-apps -array
killAll Dock
```
