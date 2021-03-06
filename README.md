# dotfiles

My dotfiles (Linux, OSX &amp; Windows) for bash &amp; zsh on PC &amp; server

## Install

After you've got `git` on your system:

```sh
git clone --recurse-submodules https://github.com/duzun/dotfiles.git ~/.dotfiles && ~/.dotfiles/init.sh 
```

Install without `git`:

```sh
curl -L -o ~/dotfiles.zip "https://github.com/duzun/dotfiles/archive/master.zip" && unzip ~/dotfiles.zip -d ~ && mv ~/dotfiles-master ~/.dotfiles && ~/.dotfiles/init.sh

```

If you don't have `git`, but latter install it and want to setup git:

```sh
~/.dotfiles/init_git.sh -f
```

## Update

There is a special alias for updating `dotfiles`:

```sh
.update
```
