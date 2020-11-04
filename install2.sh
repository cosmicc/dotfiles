
YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

USERNAME=$USER
sudo chown $USERNAME.$USERNAME /opt -R
mkdir /opt/build

echo -n "${YEL}Remove an old user (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo -n "${YEL}Username of user to remove? ${NC}"
    read delusername
    sudo deluser --remove-home $delusername
    echo "${CYN}User $delusername was removed${NC}"
fi

echo -n "${YEL}Generate RSA Keys (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then    
    echo "${CYN}Generating RSA Keys...${NC}"
    ssh-keygen -t rsa -b 4096
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
fi

echo -n "${YEL}Remove All Gnome Packages (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then    
    echo "${CYN}Shutting down X Session...${NC}"
    sudo init 3
    echo "${CYN}Removing Gnome Packages...${NC}"
    sudo apt -qq remove gnome* -y
    sudo apt -qq autoremove
fi

echo "${CYN}Adding Universe Repository...${NC}"
sudo add-apt-repository universe

echo "${CYN}Updating packages...${NC}"
sudo apt-get -qq update -y

echo "${CYN}Installing git...${NC}"
sudo apt -qq install git -y
git config pull.rebase false

if [ ! -d "dotfiles" ]; then
    echo "${CYN}Cloning Dotfiles...${NC}"
    git clone https://github.com/cosmicc/dotfiles.git 1> /dev/null
else
    echo "${CYN}Updating Dotfiles...${NC}"
    cd dotfiles
    git pull 1> /dev/null
    cd ~
fi

echo -n "${YEL}Install ZSH Shell (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing ZSH Shell...${NC}"
    sudo apt-get -qq install zsh -y

    echo "${CYN}Installing oh-my-zsh${NC}"
    wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O zmginstall.sh 1> /dev/null
    echo "${YEL}TYPE EXIT AFTER OMZSH INSTALL TO CONTINUE${NC}"
    sh ./zmginstall.sh
    rm ./zmginstall.sh -f
    
    if [ ! -f "/etc/zsh/zshrc" ]; then
        sudo cp ~/.zshrc /etc/zsh/zshrc
    fi

    if [ ! -f "/etc/zsh/dircolors" ]; then
        echo "${CYN}Installing Directory Colors...${NC}"
        sudo cp dotfiles/LS_COLORS /etc/zsh/dircolors
        sudo sh -c 'echo "test -r /etc/zsh/dircolors && eval \"\$(dircolors -b /etc/zsh/dircolors)\" || eval \"\$(dircolors -b)]\"" >> /etc/zsh/zshrc'
    fi

    if [ ! -f "/etc/zsh/promptline.sh" ]; then 
        echo "${CYN}Installing Promptline...${NC}"
        sudo cp dotfiles/promptline.sh /etc/zsh/promptline.sh
        sudo sh -c 'echo "source /etc/zsh/promptline.sh" >> /etc/zsh/zshrc'
    fi
fi

echo -n "${YEL}Install Essential System Packages (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Essential System Packages...${NC}"
    sudo apt -qq install pipenv neofetch pax p7zip-rar lm-sensors apt-transport-https ca-certificates isort curl software-properties-common openvpn libssl-dev libffi-dev nfs-common openssh-server dos2unix -y
fi

echo -n "${YEL}Install Essential Building Packages (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Essential Building Packages...${NC}"
     sudo apt -qq install build-essential make cmake automake pkg-config gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc libncurses-dev ncurses-dev linux-source -y
fi

echo -n "${YEL}Install VIM (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing VIM...${NC}"
    sudo apt-get -qq install vim -y
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim 1> /dev/null
    sudo git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim 1> /dev/null
    cp dotfiles/vimrc ~/.vimrc
    sudo cp dotfiles/vimrc /root/.vimrc
    mkdir ~/.vim/colors
    sudo mkdir /root/.vim/colors
    cp dotfiles/sublimemonokai.vim ~/.vim/colors
    sudo cp dotfiles/sublimemonokai.vim /root/.vim/colors
    vim +PluginInstall +qall
    sudo vim +PluginInstall +qall 
fi

echo -n "${YEL}Configure TRIM support on SSD (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    TRIM = 1
    echo "${CYN}Configuring TRIM support...${NC}"
    sudo apt -qq install sg3-utils lsscsi -y
    DRIVE = find /sys/ -name provisioning_mode -exec grep -H . {} + | sort
    echo -n "${YEL}Copy and Paste line Above: ${NC}"
    read scsiid
    sudo sh -c 'echo unmap > $scsiid'
    lsusb
    echo -n "${YEL}Copy and Paste Vendor ID for SSD (XXXX:123r): ${NC}"
    read avendor
    echo -n "${YEL}Copy and Paste Vendor ID for SSD (23e5:XXXX): ${NC}"
    read aproduct
    liner = 'ACTION=="add|change", ATTRS{idVendor}==$avendor, ATTRS{idProduct}==$aproduct, SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap"'
    sudo sh -c '$liner > /etc/udev/rules.d/10-trim.rules'
    sudo systemctl enable fstrim.timer
    echo "${CYN}Running TRIM on drive...${NC}"
    sudo fstrim -v /
fi

echo -n "${YEL}Install Moified Rpi config.txt (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Modified Rpi config.txt...${NC}"
    sudo cp dotfiles/templates/rpi-config.txt /boot/firmware/config.txt -f
fi

echo -n "${YEL}Force Processors to Max Speed (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Forcing Processors to Max Speed...${NC}"
    sudo sh -c 'echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'
    sudo sh -c 'echo "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" > /etc/init.d/governor'
    sudo chmod ugo+rx /etc/init.d/governor
    sudo ln -s /etc/init.d/governor /etc/rc2.d/S90governor
else
    echo -n "${YEL}Force Processors to Ramp Up at 50% (y/n)? ${NC}"
    read answer
    if [ $answer = "y" ]; then
        echo "${CYN}Forcing Processors to Ramp Up at 50%...${NC}"
        sudo sh -c 'echo 50 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold'
        sudo sh -c 'echo "echo 50 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold" > /etc/init.d/governor'
        sudo chmod ugo+rx /etc/init.d/governor
        sudo ln -s /etc/init.d/governor /etc/rc2.d/S90governor
    fi
fi

echo -n "${YEL}Install 64bit Rpi Userland (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing 64bit Rpi Userland...${NC}"
    git clone https://github.com/raspberrypi/userland.git /opt/build/userland
    cd /opt/build/userland
    mkdir build 
    cd build 
    cmake -DCMAKE_BUILD_TYPE=Release -DARM64=ON ../
    make -j4
    sudo make install
    sudo cp -rfp /opt/vc/* /usr
    cd ~
    sudo apt -qq install rpi-eeprom wiringpi -y
fi

echo -n "${YEL}Install Python3 Libraries (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Python Libraries...${NC}"
    sudo apt-get -qq install python3-dev -y
    sudo pip3 install loguru gitpython wpa-supplicant python-wifi rf-info isort flake8 maidenhead pyserial gps configparser RPi.GPIO 1> /dev/null
fi

echo -n "${YEL}Install Xubuntu-desktop (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Xubuntu-desktop...${NC}"
    sudo apt -qq install xubuntu-core^ slick-greeter libpam-kwallet4 libpam-kwallet5 -y
    sudo sh -c 'echo "[SeatDefaults]\ngreeter-session=slick-greeter\n" > /etc/lightdm/lightdm.conf'
    echo "${CYN}Installing Xubuntu-desktop Apps...${NC}"
    sudo apt -qq install app-install-data-partner gparted network-manager-openconnect-gnome network-manager-openvpn-gnome network-manager-vpnc-gnome t1-xfree86-nonfree ttf-xfree86-nonfree ttf-xfree86-nonfree-syriac xfonts-75dpi xfonts-100dpi ttf-mscorefonts-installer fonts-firacode fonts-noto chromium-browser mugshot blueman bluez catfish desktop-file-utils evince espeak file-roller firefox fwupd fwupdate gigolo gnome-calculator gnome-software gnome-system-tools indicator-application indicator-messages indicator-sound inxi libnotify-bin libnss-mdns libpam-gnome-keyring libxfce4ui-utils light-locker lightdm-gtk-greeter-settings menulibre network-manager-gnome onboard pavucontrol ristretto software-properties-gtk speech-dispatcher thunar-archive-plugin thunar-media-tags-plugin transmission-gtk ttf-ubuntu-font-family update-notifier xcursor-themes xfce4-cpugraph-plugin xfce4-dict xfce4-indicator-plugin xfce4-netload-plugin xfce4-places-plugin xfce4-power-manager xfce4-screenshooter xfce4-systemload-plugin xfce4-taskmanager xfce4-terminal xfce4-verve-plugin xfce4-whiskermenu-plugin xfpanel-switch xul-ext-ubufox terminator notepadqq vlc -y

    echo "${CYN}Extracting Wallpapers...${NC}"
    sudo sh -c "tar xvfz dotfiles/templates/wallpaper.tar.gz -C /usr/share/xfce4/backdrops"
    sudo chmod ugo+rwx /usr/share/xfce4/backdrops -R
    echo "${CYN}Restoring Xfce Settings...${NC}"
    mkdir ~/.config/xfce4/xfconf/xfce-perchannel-xml -p
    tar xvfz dotfiles/templates/settings.tar.gz -C ~/.config/xfce4/xfconf/xfce-perchannel-xml

fi

echo -n "${YEL}Remove Games (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing Games...${NC}"
    sudo apt -qq remove sgt-puzzles ristretto *sudoko libgnome-games* gnome-mines -y
fi

echo -n "${YEL}Remove CUPS Printing (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing CUPS Printing...${NC}"
    sudo apt -qq remove cups* -y
fi    

echo -n "${YEL}Remove LibreOffice (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing Libreoffice...${NC}"
    sudo apt -qq remove libreoffice* -y
fi

echo "${CYN}Upgrading packages...${NC}"
sudo apt -qq full-upgrade -y

echo "${CYN}Removing un-needed packages...${NC}"
sudo apt -qq  autoremove -y

if [ $TRIM = 1 ]; then
    echo "${CYN}Running final TRIM on Drive...${NC}"
    sudo fstrim -v /
fi

cd dotfiles
echo "${CYN}You may also want ./harden.sh ./radiotools.sh ./kalitools.sh${NC}"
echo "${CYN}Complete${NC}"
