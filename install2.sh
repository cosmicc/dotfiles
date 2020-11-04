GRN='\033[1;32m'
CYN='\033[1;36m'
MGT='\033[1;35m'
YEL='\033[1;33m'
NC='\033[0m'

attempts=5
logdir=/opt/
logfile=/opt/install2.log
USERNAME=$USER
TRIM=0

echo "${YEL}Starting the RPi Setup Installer!${NC}"

sudo chown $USERNAME.$USERNAME /opt -R
echo "Starting RPi Setup Installer - `date`" >> $logfile 

if [ ! -d /opt/build ]; then
    echo "${MGT}Missing Build Directory, Creating...${NC}"
    mkdir -p /opt/build
fi

echo -n "${YEL}Remove an old user (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo -n "${YEL}Username of user to remove? ${NC}"
    read delusername
    sudo deluser --remove-home $delusername
    echo "${CYN}User $delusername was removed${NC}"
fi

if [ ! -d ~/.ssh ]; then    
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
    sudo sh -c "apt -qq remove gnome* -y >> $logfile 2>&1"
    sudo sh -c "apt -qq autoremove -y >> $logfile 2>&1"
fi

echo "${CYN}Adding Universe Repository...${NC}"
sudo sh -c "add-apt-repository universe -y >> $logfile 2>&1"

echo "${CYN}Updating OS Package List...${NC}"
sudo sh -c "dpkg --configure -a >> $logfile 2>&1"
sudo sh -c "apt -qq update -y >> $logfile 2>&1"

echo "${CYN}Installing Git...${NC}"
sudo sh -c "apt -qq install git -y >> $logfile 2>&1"
git config pull.rebase false >> $logfile 2>&1

if [ ! -d "rpisetup" ]; then
    echo "${CYN}Cloning Install Scripts...${NC}"
    git clone https://github.com/cosmicc/dotfiles.git rpisetup >> $logfile 2>&1
else
    echo "${CYN}Updating Install Scripts...${NC}"
    cd rpisetup
    git pull >> $logfile 2>&1
    cd ~
fi

echo -n "${YEL}Install ZSH Shell (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing ZSH Shell...${NC}"
    sudo sh -c "apt-get -qq install zsh -y >> $logfile 2>&1"
    echo "${CYN}Installing oh-my-zsh${NC}"
    wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O zmginstall.sh >> $logfile 2>&1
    echo "${YEL}TYPE EXIT AFTER OMZSH INSTALL TO CONTINUE${NC}"
    sh ./zmginstall.sh >> $logfile 2>&1
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

count=1
while [ $count -le $attempts ]; do
    echo "${CYN}Installing Essential System Packages (Attempt #$count)...${NC}"
    sudo sh -c "apt -qq install pipenv neofetch pax p7zip-rar lm-sensors apt-transport-https ca-certificates isort curl software-properties-common openvpn libssl-dev libffi-dev nfs-common openssh-server dos2unix -y >> $logfile 2>&1"
    if [ $? -ne 0 ]; then
        if [ $count -eq $attempts ]; then
            echo "Critical Install Error! See: $logfile"
            exit 1
        else
            ((count=count+1))
        fi    
    else
        count=99
    fi
done

echo -n "${YEL}Install Essential Build Packages (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then
    count=1
    while [ $count -le $attempts ]; do
        echo "${CYN}Installing Essential Building Packages (Attempt #$count)...${NC}"
        sudo sh -c "apt -qq install build-essential make cmake automake pkg-config gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc libncurses-dev ncurses-dev linux-source ccache sdcc -y >> $logfile 2>&1"
        if [ $? -ne 0 ]; then
            if [ $count -eq $attempts ]; then
                echo "Critical Install Error! See: $logfile"
                exit 1
            else
                ((count=count+1))
            fi    
        else
            count=99
        fi
    done
fi

if [ ! -d ~/.vim/bundle/Vundle.vim ] || [ ! -d ~/.vim/colors ]; then 
    echo "${CYN}Installing VIM...${NC}"
    sudo sh -c "apt-get -qq install vim -y >> $logfile 2>&1"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim >> $logfile 2>&1
    sudo git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim >> $logfile 2>&1
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
    TRIM=1
    echo "${CYN}Configuring TRIM support...${NC}"
    sudo sh -c "apt -qq install sg3-utils lsscsi -y >> $logfile 2>&1"
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
    sudo sh -c "systemctl enable fstrim.timer >> $logfile 2>&1"
    echo "${CYN}Running TRIM on drive...${NC}"
    sudo fstrim -v /
fi

file1=`md5 dotfiles/templates/rpi-config.txt`
file2=`md5 /boot/firmware/config.txt`
if [ $file1 = $file2 ]; then 
    echo "${CYN}Modified RPi config.txt already in place...${NC}"
else
    echo "${CYN}Installing Modified RPi config.txt...${NC}"
    sudo cp dotfiles/templates/rpi-config.txt /boot/firmware/config.txt -f
fi

SG=`sudo cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
TH=`sudo cat /sys/devices/system/cpu/cpufreq/ondemand/up_threshold`
echo "CPU Governor: $SG"
echo "CPU RampUp: $TH%"
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

echo "${CYN}Looking for RPi Userland...${NC}"
VC=`find /usr/bin /opt -name vcgencmd`
if [ ${#VC} -gt 0 ]; then
    echo "${CYN}RPi Userland Already Exists.${NC}" 
else
    echo -n "${YEL}RPi Userland not found! Install it (y/n)? ${NC}"
    read answer
    if [ $answer = "y" ]; then 
        echo "${CYN}Installing 64bit RPi Userland...${NC}"
        git clone https://github.com/raspberrypi/userland.git /opt/build/userland
        cd /opt/build/userland
        mkdir build 
        cd build 
        cmake -DCMAKE_BUILD_TYPE=Release -DARM64=ON ../ >> $logfile 2>&1
        make -j4 >> $logfile 2>&1
        sudo sh -c "make install >> $logfile 2>&1"
        sudo cp -rfp /opt/vc/* /usr
        cd ~
        sudo sh -c "apt -qq install rpi-eeprom wiringpi -y >> $logfile 2>&1"
   fi     
fi

echo -n "${YEL}Install Python3 Libraries (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Python Libraries...${NC}"
    sudo sh -c "apt-get -qq install python3-dev -y >> $logfile 2>&1"
    sudo sh -c "pip3 install loguru gitpython wpa-supplicant python-wifi rf-info isort flake8 maidenhead pyserial gps configparser RPi.GPIO >> $logfile 2>&1"
fi

echo -n "${YEL}Install Xubuntu-desktop (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    count=1
    while [ $count -le $attempts ]; do
        echo "${CYN}Installing Xubuntu-desktop (Attempt #$count)...${NC}"
        sudo sh -c "apt -qq install xubuntu-core^ slick-greeter libpam-kwallet4 libpam-kwallet5 -y >> $logfile 2>&1"
        if [ $? -ne 0 ]; then
            if [ $count -eq $attempts ]; then
                echo "Critical Install Error! See: $logfile"
                exit 1
            else
                ((count=count+1))
            fi    
        else
            count=99
        fi
    done
    sudo sh -c 'echo "[SeatDefaults]\ngreeter-session=slick-greeter\n" > /etc/lightdm/lightdm.conf'
    count=1
    while [ $count -le $attempts ]; do
        echo "${CYN}Installing Xubuntu-desktop Apps (Attempt #$count)...${NC}"
    sudo sh -c "apt -qq install app-install-data-partner gparted network-manager-openconnect-gnome network-manager-openvpn-gnome network-manager-vpnc-gnome t1-xfree86-nonfree ttf-xfree86-nonfree ttf-xfree86-nonfree-syriac xfonts-75dpi xfonts-100dpi ttf-mscorefonts-installer fonts-firacode fonts-noto chromium-browser mugshot blueman bluez catfish desktop-file-utils evince espeak file-roller firefox fwupd fwupdate gigolo gnome-calculator gnome-software gnome-system-tools indicator-application indicator-messages indicator-sound inxi libnotify-bin libnss-mdns libpam-gnome-keyring libxfce4ui-utils light-locker lightdm-gtk-greeter-settings menulibre network-manager-gnome onboard pavucontrol ristretto software-properties-gtk speech-dispatcher thunar-archive-plugin thunar-media-tags-plugin transmission-gtk ttf-ubuntu-font-family update-notifier xcursor-themes xfce4-cpugraph-plugin xfce4-dict xfce4-indicator-plugin xfce4-netload-plugin xfce4-places-plugin xfce4-power-manager xfce4-screenshooter xfce4-systemload-plugin xfce4-taskmanager xfce4-terminal xfce4-verve-plugin xfce4-whiskermenu-plugin xfpanel-switch xul-ext-ubufox terminator notepadqq vlc -y >> $logfile 2>&1"
        if [ $? -ne 0 ]; then
            if [ $count -eq $attempts ]; then
                echo "Critical Install Error! See: $logfile"
                exit 1
            else
                ((count=count+1))
            fi    
        else
            count=99
        fi
    done
    echo "${CYN}Extracting Wallpapers...${NC}"
    sudo sh -c "tar xvfz dotfiles/templates/wallpaper.tar.gz -C /usr/share/xfce4/backdrops >> $logfile 2>&1"
    sudo chmod ugo+rwx /usr/share/xfce4/backdrops -R
    echo "${CYN}Restoring Xfce Settings...${NC}"
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
    tar xvfz dotfiles/templates/settings.tar.gz -C ~/.config/xfce4/xfconf/xfce-perchannel-xml >> $logfile 2>&1
fi

echo -n "${YEL}Remove Games (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing Games...${NC}"
    sudo sh -c "apt -qq remove sgt-puzzles ristretto *sudoko libgnome-games* gnome-mines -y >> $logfile 2>&1"
fi

echo -n "${YEL}Remove CUPS Printing (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing CUPS Printing...${NC}"
    sudo sh -c "apt -qq remove cups* -y >> $logfile 2>&1"
fi    

echo -n "${YEL}Remove LibreOffice (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Removing Libreoffice...${NC}"
    sudo sh -c "apt -qq remove libreoffice* -y >> $logfile 2>&1"
fi

count=1
while [ $count -le $attempts ]; do
    echo "${CYN}Upgrading OS Packages (Attempt #$count)...${NC}"
    sudo sh -c "apt -qq full-upgrade -y >> $logfile 2>&1"
    if [ $? -ne 0 ]; then
        if [ $count -eq $attempts ]; then
            echo "Critical Install Error! See: $logfile"
            exit 1
        else
            ((count=count+1))
        fi    
    else
        count=99
    fi
done


echo "${CYN}Removing un-needed packages...${NC}"
sudo sh -c "apt -qq  autoremove -y >> $logfile 2>&1"

if [ $TRIM -eq 1 ]; then
    echo "${CYN}Running final TRIM on Drive...${NC}"
    sudo fstrim -v /
fi

cd rpisetup
echo "${YEL}You may also want ./harden.sh ./radiotools.sh ./kalitools.sh${NC}"
echo "${GRN}Install Complete${NC}"
