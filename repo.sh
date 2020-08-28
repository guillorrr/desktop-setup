nkr_sources() {
  local name="$1"
  local source="$2"
        if [ $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -c "$name") -eq 0 ];
        then
                echo "$source" | sudo tee -a /etc/apt/sources.list.d/"$name".list
                printf "$ppa add successful"
        fi
}

nkr_ppa() {
  local ppa="$1"
   if [ $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null | grep -c "$ppa") -eq 0 ];
    then
       echo "Adding ppa:$ppa"
       sudo add-apt-repository -y ppa:$ppa;
    fi
}

# nkr_sources sublime-text "deb https://download.sublimetext.com/ apt/stable/"
nkr_ppa transmissionbt/ppa
