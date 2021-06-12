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
        echo "$source" | sudo tee -a /etc/apt/sources.list.d/"$ppa".list
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
        sudo snap install "$package" --"$version";
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

nkr_composer(){
  local composer=$1
    if [ $(composer global show 2>/dev/null | grep -c "$composer") -eq 0 ];
      then
        nkr_echo "Installing $composer"
        composer global require "$composer"
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
nkr_sources google-chrome "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

# Amazon Workspaces Client 
wget -q -O - https://workspaces-client-linux-public-key.s3-us-west-2.amazonaws.com/ADB332E7.asc | sudo apt-key add -
nkr_sources workspacesclient "deb [arch=amd64] https://d3nt0h4h6pmmc4.cloudfront.net/ubuntu bionic main"

# Beekeeper Studio
wget --quiet -O - https://deb.beekeeperstudio.io/beekeeper.key | sudo apt-key add -
nkr_sources beekeeper-studio-app "deb https://deb.beekeeperstudio.io stable main"

# Microsoft Teams
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -       
nkr_sources teams "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main"

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
nkr_sources spotify-client "deb http://repository.spotify.com stable non-free"

# code
wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - 
nkr_sources code "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

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
# audacity
nkr_ppa ubuntuhandbook1/audacity
# inkscape
nkr_ppa inkscape.dev/stable
# openscad
nkr_ppa openscad/releases
# vidcutter
nkr_ppa ozmartian/apps

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
nkr_install xrdp
nkr_install samba

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
nkr_install cpu-x
nkr_install libimage-exiftool-perl
nkr_install ffmpegthumbnailer

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
#nkr_install umake
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
nkr_install php
nkr_install php-mysql
nkr_install php-sqlite3
nkr_install php-curl
nkr_install php-json
nkr_install php-cgi
nkr_install php-fpm
nkr_install php-cli
nkr_install php-pear
nkr_install php-gd
nkr_install php-imagick
nkr_install php-dev
nkr_install php-intl
nkr_install php-common 
nkr_install php-mbstring 
nkr_install php-xml 
nkr_install php-xmlrpc
nkr_install php-zip
nkr_install php-bcmath
nkr_install openssl

nkr_install php8.0
nkr_install php8.0-mysql
nkr_install php8.0-sqlite3
nkr_install php8.0-curl
nkr_install php8.0-json
nkr_install php8.0-cgi
nkr_install php8.0-xsl
nkr_install php8.0-fpm
nkr_install php8.0-cli
nkr_install php8.0-gd
nkr_install php8.0-imagick
nkr_install php8.0-dev
nkr_install php8.0-intl
nkr_install php8.0-common
nkr_install php8.0-mbstring 
nkr_install php8.0-xml
nkr_install php8.0-xmlrpc 
nkr_install php8.0-zip
nkr_install php8.0-bcmath
# nkr_install php8.0-opcache 

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

#nodejs
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
nkr_install nodejs

# laravel
# composer global require laravel/installer
nkr_composer "laravel/installer:^4.0"

# docker
# apt-cache policy docker-ce
nkr_ppa_install docker-ce
# sudo systemctl status docker
# Granting rights...
sudo usermod -aG docker $(whoami)
# Docker Compose installation started...
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# database
nkr_install mysql-server
nkr_install mysql-client
nkr_install phpmyadmin
nkr_install postgresql
nkr_install postgresql-contrib
nkr_install phppgadmin
nkr_install sqlite3
nkr_install sqlitebrowser

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

# Beekeeper Studio
nkr_ppa_install beekeeper-studio

# Microsoft Teams
nkr_ppa_install teams

# Spotify
nkr_ppa_install spotify-client

# VS Code
nkr_ppa_install code

# vlc
nkr_install vlc
nkr_install vlc-plugin-access-extra
nkr_install libbluray-bdj
nkr_install libdvdcss2

# audacity
nkr_install audacity

# Transmission
nkr_install transmission-gtk
xdg-mime default transmission-gtk.desktop x-scheme-handler/magnet

# Wine
nkr_install wine-stable

# Shutter
nkr_install shutter

# inkscape
nkr_install inkscape

# pinta
nkr_install pinta

# openscad
nkr_install openscad

# freecad
nkr_install freecad

# vidcutter
nkr_install vidcutter

# Telegram
nkr_install telegram-desktop
# nkr_install telegram-cli telegram-purple

# gdebi
nkr_install gdebi

# download files
cd /tmp

# wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

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

# gitkraken
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
nkr_dpkg gitkraken-amd64.deb

# slack
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.10.3-amd64.deb
nkr_dpkg slack-desktop-4.10.3-amd64.deb

# discord
wget https://dl.discordapp.net/apps/linux/0.0.12/discord-0.0.12.deb
nkr_dpkg discord-0.0.12.deb

# skype
wget https://repo.skype.com/latest/skypeforlinux-64.deb
nkr_dpkg skypeforlinux-64.deb

# zoom
wget https://zoom.us/client/latest/zoom_amd64.deb
nkr_dpkg zoom_amd64.deb

#  mysql-workbench
wget https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.22-1ubuntu20.04_amd64.deb
nkr_dpkg mysql-workbench-community_8.0.22-1ubuntu20.04_amd64.deb

#  mysql-workbench
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
nkr_dpkg dbeaver-ce_latest_amd64.deb

# mega.nz
wget https://mega.nz/linux/MEGAsync/xUbuntu_$(lsb_release -rs)/amd64/megasync-xUbuntu_$(lsb_release -rs)_amd64.deb -O megasync.deb
wget https://mega.nz/linux/MEGAsync/xUbuntu_$(lsb_release -rs)/amd64/nautilus-megasync-xUbuntu_$(lsb_release -rs)_amd64.deb -O nautilus-megasync.deb

nkr_dpkg megasync.deb
nkr_dpkg nautilus-megasync.deb
sudo apt -f install

# youtube-dl
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl

# blender
wget https://www.blender.org/download/Blender2.92/blender-2.92.0-linux64.tar.xz
sudo tar -xvf blender-2.92.0-linux64.tar.xz -C /opt
sudo mv /opt/blender-2.92.0-linux64 /opt/blender
sudo ln -s /opt/blender/blender /usr/bin/
touch ~/.local/share/applications/blender.desktop
echo '[Desktop Entry]\nName=Blender\nExec=blender\nComment=\nTerminal=false\nIcon=/opt/blender/blender.svg\nType=Application' >> ~/.local/share/applications/blender.desktop

# datagrip
wget https://download.jetbrains.com/datagrip/datagrip-2020.3.2.tar.gz
sudo tar -xf datagrip-2020.3.2.tar.gz -C /opt
sudo mv /opt/DataGrip-* /opt/datagrip
sudo sh /opt/datagrip/bin/datagrip.sh

# phpstorm
wget https://download.jetbrains.com/webide/PhpStorm-2021.1.1.tar.gz
sudo tar -xf PhpStorm-2021.1.1.tar.gz -C /opt
sudo mv /opt/PhpStorm-* /opt/phpstorm
sudo sh /opt/phpstorm/bin/phpstorm.sh

# gimp
wget https://download.gimp.org/mirror/pub/gimp/v2.10/gimp-2.10.22.tar.bz2
sudo tar -xjf gimp-2.10.22.tar.bz2 -C /opt
sudo mv /opt/gimp-2.10.22 /opt/gimp
sudo sh ./opt/gimp/bin/gimp.sh
nkr_install gimp-cbmplugs
nkr_install gimp-dcraw
nkr_install gimp-dds
nkr_install gimp-gap
nkr_install gimp-gluas
nkr_install gimp-gmic
nkr_install gimp-gutenprint
nkr_install gimp-normalmap
nkr_install gimp-texturize

# prusa slicer
wget https://cdn.prusa3d.com/downloads/drivers/prusa3d_linux_2_3_1.zip
wget https://raw.githubusercontent.com/prusa3d/PrusaSlicer/master/resources/icons/PrusaSlicer_128px.png
sudo unzip prusa3d_linux_2_3_1.zip -d /opt/prusaslicer
sudo mv /opt/prusaslicer/PrusaSlicer-2.3.1+linux-x64-202104161339.AppImage /opt/prusaslicer/PrusaSlicer.AppImage
sudo mv /tmp/PrusaSlicer_128px.png /opt/prusaslicer/PrusaSlicer.png
sudo rm /opt/prusaslicer/sampleobjects-info.txt
sudo chmod a+rx /opt/prusaslicer/PrusaSlicer.AppImage
sudo chmod a+rx /opt/prusaslicer/PrusaSlicer.png
touch ~/.local/share/applications/prusaslicer.desktop
echo '[Desktop Entry]\nName=PrusaSlicer\nExec=/opt/prusaslicer/PrusaSlicer.AppImage\nComment=\nTerminal=false\nIcon=/opt/prusaslicer/PrusaSlicer.png\nType=Application' >> ~/.local/share/applications/prusaslicer.desktop

# cura slicer
wget https://storage.googleapis.com/software.ultimaker.com/cura/Ultimaker_Cura-4.9.0.AppImage
wget https://raw.githubusercontent.com/Ultimaker/Cura/master/icons/cura-128.png
sudo mkdir /opt/cura
sudo mv Ultimaker_Cura-4.9.0.AppImage /opt/cura/Ultimaker_Cura.AppImage
sudo mv /tmp/cura-128.png /opt/cura/Ultimaker_Cura.png
sudo chmod a+rx /opt/cura/Ultimaker_Cura.AppImage
sudo chmod a+rx /opt/cura/Ultimaker_Cura.png
touch ~/.local/share/applications/cura.desktop
echo '[Desktop Entry]\nName=Ultimaker Cura\nExec=/opt/cura/Ultimaker_Cura.AppImage\nComment=\nTerminal=false\nIcon=/opt/cura/Ultimaker_Cura.png\nType=Application' >> ~/.local/share/applications/cura.desktop

# meshlab slicer
wget https://github.com/cnr-isti-vclab/meshlab/releases/download/Meshlab-2020.12/MeshLab2020.12-linux.AppImage
wget https://www.meshlab.net/img/meshlabjsLogo.png
sudo mkdir /opt/meshlab
sudo mv MeshLab2020.12-linux.AppImage /opt/meshlab/MeshLab.AppImage
sudo mv /tmp/meshlabjsLogo.png /opt/meshlab/MeshLab.png
sudo chmod a+rx /opt/meshlab/MeshLab.AppImage
sudo chmod a+rx /opt/meshlab/MeshLab.png
touch ~/.local/share/applications/meshlab.desktop
echo '[Desktop Entry]\nName=MeshLab\nExec=/opt/meshlab/MeshLab.AppImage\nComment=\nTerminal=false\nIcon=/opt/meshlab/MeshLab.png\nType=Application' >> ~/.local/share/applications/meshlab.desktop

# tinyMediaManager
wget https://release.tinymediamanager.org/v4/dist/tmm_4.1.4_linux.tar.gz
sudo tar -xf tmm_4.1.4_linux.tar.gz -C /opt
sudo chown guillo:guillo -R /opt/tinyMediaManager
sudo chmod a+rx /opt/tinyMediaManager
sudo ln -s /opt/tinyMediaManager/tinyMediaManager /usr/bin/
touch ~/.local/share/applications/tinyMediaManager.desktop
echo '[Desktop Entry]\nName=tinyMediaManager\nExec=tinyMediaManager\nComment=\nTerminal=false\nIcon=/opt/tinyMediaManager/tmm.png\nType=Application' >> ~/.local/share/applications/tinyMediaManager.desktop

# poedit
wget https://github.com/vslavik/poedit/releases/download/v2.4.2-oss/poedit-2.4.2.tar.gz
sudo tar -xf poedit-2.4.2.tar.gz -C /opt
sudo mv /opt/poedit-2.4.2 /opt/poedit
sudo chown guillo:guillo -R /opt/poedit
sudo chmod a+rx /opt/poedit
cd /opt/poedit
nkr_install libicu-dev
nkr_install libgtkspell-dev
nkr_install libdb++-dev
nkr_install liblucene++-dev
nkr_install libboost-dev
nkr_install libboost-regex-dev
nkr_install libboost-system-dev
nkr_install libwxgtk3.0-gtk3-dev
nkr_install libcld2-0
nkr_install libgtkspell3-3-dev
./configure
make
make install

# download files
cd /tmp

# for snap
cd ~

# Snap
# nkr_snap spotify classic
# nkr_snap audacity
# nkr_snap gitkraken
# nkr_snap slack classic
# nkr_snap discord
# nkr_snap skype classic
# nkr_snap zoom-client
# nkr_snap beekeeper-studio
# nkr_snap code classic
# nkr_snap gimp
# nkr_snap inkscape
# nkr_snap datagrip classic
# nkr_snap phpstorm classic
# nkr_snap blender classic
# nkr_snap openscad
# nkr_snap freecad
# nkr_snap prusa-slicer
# nkr_snap cura-slicer edge
# nkr_snap meshlab
# nkr_snap vidcutter
# nkr_snap poedit
# nkr_snap minuet

# Grapics
# nkr_snap photogimp
# nkr_snap vectr
# nkr_snap pinta-james-carroll

# IDE
nkr_snap arduino

# VS Code extensions

nkr_code shan.code-settings-sync
nkr_code file-icons.file-icons
nkr_code geeebe.duplicate
nkr_code ms-vscode.theme-1337
nkr_code annsk.alignment
nkr_code shakram02.bash-beautify
nkr_code mikestead.dotenv
nkr_code editorconfig.editorconfig

# laravel 
nkr_code onecentlin.laravel-extension-pack

# php
nkr_code felixfbecker.php-pack

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
# composer global require cpriego/valet-linux
nkr_composer cpriego/valet-linux
# restarting network-manager
if [ ! $(composer global show 2>/dev/null | grep -c "valet") -eq 0 ];
  then
    nkr_echo "Installing valet"
    valet install
fi

#restart cache
sudo fc-cache -f -v
