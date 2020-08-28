#!/bin/bash
nkr_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

nkr_sources() {
  local ppa="$1"
  local source="$2"
    if [ $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -c "$ppa") -eq 0 ];
      then
        nkr_echo "$ppa add successful"
        echo "$source" | sudo tee -a /etc/apt/sources.list.d/"$name".list
    fi
}

nkr_ppa() {
  local ppa="$1"
    if [ $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -c "$ppa") -eq 0 ];
      then
        nkr_echo "Adding ppa:$ppa"
        sudo add-apt-repository -y ppa:$ppa;
    fi
}

nkr_ppa_install() {
  local ppa="$1"
    if [ ! $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -c "$ppa") -eq 0 ];
      then
        nkr_echo "Installing $ppa"
        sudo aptitude install -y "$ppa";
    fi
}

nkr_install() {
  local package="$1"
    if [ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed") -eq 0 ];
      then
        nkr_echo "Installing $package"
        sudo aptitude install -y "$package";
    fi
}

nkr_snap() {
  local package="$1"
  local version="$2"
    if [ $(snap info "$package" 2>/dev/null | grep -c "installed") -eq 0 ];
      then
        nkr_echo "Installing $package"
        sudo snap install "$package" --channel="$version";
    fi
}

nkr_code() {
  local package="$1"
    if [ $(code --list-extensions 2>/dev/null | grep -c "$package") -eq 0 ];
      then
        nkr_echo "Installing $package"
        code --install-extension "$package";
    fi
}

nkr_dpkg(){
  local package=$(dpkg-deb -f "$1" Package 2>/dev/null)
    if [ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed") -eq 0 ];
      then
        nkr_echo "Installing $package"
        sudo gdebi "$1" -n
    fi
}

export_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
set -e

if [[ ! -d "$HOME/.bin/" ]]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

nkr_echo "Updating system packages ..."
  if command -v aptitude >/dev/null; then
    nkr_echo "Using aptitude ..."
  else
    nkr_echo "Installing aptitude ..."
    sudo apt install aptitude
  fi

sudo aptitude update
sudo aptitude upgrade

# internet
nkr_install wget
nkr_install curl
nkr_install whois
nkr_install net-tools
nkr_install nmap
nkr_install ping
nkr_install apt-transport-https
nkr_install ca-certificates
nkr_install gnupg-agent

# git
nkr_install git

#Installing sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
nkr_sources sublime-text "deb https://download.sublimetext.com/ apt/stable/"

# Google Cloud SDK
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
nkr_sources google-cloud-sdk "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main"

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
nkr_sources docker-ce "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# google chrome (also for development)
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
nkr_sources google-chrome-stable "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

# Amazon Workspaces Client 
wget -q -O - https://workspaces-client-linux-public-key.s3-us-west-2.amazonaws.com/ADB332E7.asc | sudo apt-key add -
nkr_sources workspacesclient "deb [arch=amd64] https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu bionic main"

# Balena Etcher
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
# nkr_sources balena-etcher-electron "deb https://deb.etcher.io stable etcher"

# php
nkr_ppa ondrej/php
# python
nkr_ppa deadsnakes/ppa
# vlc
nkr_ppa videolan/master-daily
# Transmission
nkr_ppa transmissionbt/ppa
# Shutter
nkr_ppa linuxuprising/shutter
# TLP - saves battery when Ubuntu is installed on Laptops
nkr_ppa linrunner/tlp

sudo aptitude update

# Installing build essentials
nkr_install build-essential
nkr_install libssl-dev
nkr_install software-properties-common

# text editing
nkr_install vim
nkr_install sed

# file system tools
nkr_install tree
nkr_install silversearcher-ag
nkr_install xclip

# system monitoring
nkr_install htop
nkr_install ncdu

# terminal system tools
nkr_install terminator
nkr_install screen
nkr_install ssh
nkr_install rsync
nkr_install tmux
nkr_install putty
nkr_install expect

# Password Safety
nkr_install passwdqc

# crypt setup
nkr_install ecryptfs-utils
nkr_install cryptsetup
nkr_install gparted

# mount disks
nkr_install exfat-fuse
nkr_install exfat-utils
nkr_install hfsplus
nkr_install hfsutils
nkr_install ntfs-3g

# mount devices
nkr_install mtp-tools
nkr_install ipheth-utils
nkr_install ideviceinstaller
nkr_install ifuse

# balena etcher
nkr_ppa_install balena-etcher-electron

# compression
nkr_install unace
nkr_install unrar
nkr_install zip
nkr_install unzip
nkr_install p7zip-full
nkr_install p7zip-rar
nkr_install sharutils
nkr_install rar
nkr_install uudeview
nkr_install mpack
nkr_install arj
nkr_install cabextract
nkr_install file-roller

# print
nkr_install printer-driver-all

# aircrack
nkr_install aircrack-ng

# tools
nkr_install gprename
nkr_install renrot

# multimedia codecs
nkr_install ubuntu-restricted-extras
nkr_install ffmpeg
nkr_install libavcodec-extra

# RPM and alien - sometimes used to install software packages
nkr_install rpm
nkr_install alien
nkr_install dpkg-dev
nkr_install debhelper

# Sticky Notes
nkr_install xpad

# alternative gnome desktop (and **REMOVE** the ubuntu dock)
nkr_install gnome-session-flashback
#sudo apt remove -y gnome-shell-extension-ubuntu-dock

# Gnome system tools
nkr_install gnome-tweak-tool
nkr_install gkrellm

# Conky
nkr_install conky
nkr_install conky-all
nkr_install lm-sensors
nkr_install hddtemp

# TLP - saves battery when Ubuntu is installed on Laptops
sudo apt remove laptop-mode-tools
nkr_install tlp
nkr_install tlp-rdw
nkr_install smartmontools
nkr_install ethtool
sudo tlp start

# buttons to right
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# development / ops
nkr_install make
nkr_install cmake
nkr_install g++
nkr_install gcc
nkr_install gitk

# FileZilla - a FTP client
nkr_install filezilla

# JDK and JRE
nkr_install default-jre
nkr_install default-jdk

# nkr_install openjdk-8-jdk 
# nkr_snap intellij-idea-community
nkr_install python3
nkr_install python3.8
nkr_install python3-pip
nkr_install python3-virtualenv
nkr_install pyflakes
nkr_install pylint
nkr_install pipenv
pip3 install --upgrade pip
# pip install --user virtualenv
# pip install --user virtualenvwrapper
export_to_zshrc 'export PATH="$HOME/.local/bin:$PATH"'
export PATH="$HOME/.local/bin:$PATH"
# export_to_zshrc 'export WORKON_HOME="$HOME/.virtualenvs"'
# export_to_zshrc 'source "$HOME/.local/bin/virtualenvwrapper.sh"'

# not that the pipenv installation through apt might not work, consider installing using pip globally
# or use pipenv as python3 module "python3 -m pipenv ..."
# you might want to extend your bashrc using this alias:
# alias pipenv3="python3 -m pipenv"

# see https://pipenv-searchable.readthedocs.io/
# pip3 install pipenv --user

# php
nkr_install php7.4
nkr_install php7.4-mysql
nkr_install php7.4-curl
nkr_install php7.4-json
nkr_install php7.4-cgi
nkr_install php7.4-xsl
nkr_install php7.4-fpm
nkr_install php-cli

# composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
# HASH=`curl -sS https://composer.github.io/installer.sig`
# php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo rm composer-setup.php -f
if [[ -d "$HOME/.composer/" ]]; then
  sudo chown -R $USER ~/.composer/
fi
export_to_zshrc 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"'
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# laravel
nkr_install php7.4-common
nkr_install php7.4-bcmath
nkr_install openssl
nkr_install php7.4-json
nkr_install php7.4-mbstring
nkr_install php7.4-zip
composer global require laravel/installer

# docker
# apt-cache policy docker-ce
nkr_ppa_install docker-ce
# sudo systemctl status docker
# Granting rights...
sudo usermod -aG docker $(whoami)
# Docker Compose installation started...
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# virtualbox
nkr_install virtualbox
nkr_install vagrant
nkr_install ansible
# KVM acceleration and cpu checker
nkr_install cpu-checker
nkr_install qemu
nkr_install qemu-kvm
nkr_install qemu-utils
nkr_install libvirt-daemon-system 
nkr_install libvirt-clients
nkr_install bridge-utils
nkr_install virt-manager

nkr_install remmina
nkr_install rclone

# sublime text
nkr_ppa_install sublime-text

# install google chrome (also for development)
nkr_ppa_install google-chrome-stable

# Google Cloud SDK
nkr_ppa_install google-cloud-sdk

# Amazon Workspaces Client 
nkr_ppa_install workspacesclient

# vlc
nkr_install vlc
nkr_install vlc-plugin-access-extra
nkr_install libbluray-bdj
nkr_install libdvdcss2

# Transmission
nkr_install transmission-gtk
xdg-mime default transmission-gtk.desktop x-scheme-handler/magnet

# Wine
nkr_install wine-stable

# Shutter
nkr_install shutter

# Telegram
nkr_install telegram-desktop
# nkr_install telegram-cli telegram-purple

# gdebi
nkr_install gdebi

# download files
cd /tmp

# dropbox
wget https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb -O dropbox_2020.03.04_amd64.deb
nkr_install python3-gpg
nkr_dpkg dropbox_2020.03.04_amd64.deb

# teamviewer
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
nkr_dpkg teamviewer_amd64.deb

# pdfsam
wget https://github.com/torakiki/pdfsam/releases/download/v4.1.4/pdfsam_4.1.4-1_amd64.deb
nkr_dpkg pdfsam_4.1.4-1_amd64.deb

# mega.nz
wget https://mega.nz/linux/MEGAsync/xUbuntu_$(lsb_release -rs)/amd64/megasync-xUbuntu_$(lsb_release -rs)_amd64.deb -O megasync.deb
wget https://mega.nz/linux/MEGAsync/xUbuntu_$(lsb_release -rs)/amd64/nautilus-megasync-xUbuntu_$(lsb_release -rs)_amd64.deb -O nautilus-megasync.deb

nkr_dpkg megasync.deb
nkr_dpkg nautilus-megasync.deb
sudo apt -f install

# youtube-dl
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl

# for snap
cd ~

# Music
nkr_snap spotify classic
nkr_snap audacity
nkr_snap minuet

nkr_snap poedit
nkr_snap geany-gtk edge
nkr_snap gitkraken

# Chat
nkr_snap slack classic
nkr_snap discord
nkr_snap skype classic
nkr_snap zoom-client

# 3D
nkr_snap blender classic
nkr_snap freecad
nkr_snap meshlab
nkr_snap openscad
nkr_snap prusa-slicer
nkr_snap cura-slicer edge

# Grapics
nkr_snap gimp
nkr_snap photogimp
nkr_snap inkscape
nkr_snap vectr
nkr_snap pinta-james-carroll
nkr_snap vidcutter
nkr_snap beekeeper-studio

#Arduino
nkr_snap arduino

# MS Visual Studio Code
nkr_snap code classic

nkr_code shan.code-settings-sync
nkr_code file-icons.file-icons
nkr_code geeebe.duplicate

# python
nkr_code ms-python.python
nkr_code donjayamanne.python-extension-pack

# devops
nkr_code ms-azuretools.vscode-docker

# git
nkr_code waderyan.gitblame
nkr_code donjayamanne.githistory

# wordpress
nkr_code ashiqkiron.gutensnip
nkr_code tungvn.wordpress-snippet
nkr_code hridoy.wordpress
nkr_code wordpresstoolbox.wordpress-toolbox
nkr_code jpagano.wordpress-vscode-extensionpack

# ssh
nkr_code ms-vscode-remote.remote-ssh
nkr_code ms-vscode-remote.remote-ssh-edit
nkr_code ms-vscode-remote.remote-containers

# pretty
nkr_code esbenp.prettier-vscode

# spanish
nkr_code ms-ceintl.vscode-language-pack-es

# zsh
nkr_install zsh
if [[ ! -d "$HOME/.oh-my-zsh/" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
#chsh -s $(which zsh)

# valet
nkr_install jq
nkr_install xsel
nkr_install libnss3-tools
composer global require cpriego/valet-linux
# restarting network-manager
valet install

#restart cache
sudo fc-cache -f -v