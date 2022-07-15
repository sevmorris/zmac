

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
$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install plugins
<br>

```
$ cd ~/.oh-my-zsh/plugins
$ git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
$ git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Step 2

Clone this repo and run install script
<br>

```
$ cd ~
$ git clone https://github.com/sevmorris/macstrap.git && cd macstrap && chmod +x install
$ bash ./install
$ cd ~
```


## Step 3

Switch to Homebrew's Zsh
<br>

M1
```
$ sudo -i
$ echo /opt/homebrew/bin/zsh >> /etc/shells
$ exit
$ chsh -s /opt/homebrew/bin/zsh
```

<br>

Intel
```
$ sudo -i
$ echo /usr/local/bin/zsh >> /etc/shells
$ exit
$ chsh -s /usr/local/bin/zsh
```

Restart the terminal or open a new tab


## Step 4

Clean up (optional)
<br>

```
$ rm -r $HOME/macstrap
```

## Step X

Use some new commands to clean up/update Homebrew & packages

```
$ brewup
$ topgrade
```
