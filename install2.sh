
YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

echo -n "${YEL}Generate RSA Keys (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then    
    echo "${CYN}Generating RSA Keys...${NC}"
    ssh-keygen -t rsa -b 4096
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa
fi

if [ ! -d "dotfiles" ]; then
    echo "${CYN}Cloning Dotfiles...${NC}"
    git clone https://github.com/cosmicc/dotfiles.git 1> /dev/null
else
    echo "${CYN}Updating Dotfiles...${NC}"
    git pull dotfiles 1> /dev/null
fi

echo "${CYN}Updating packages...${NC}"
sudo apt-get -qq update -y

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
    
    if [ ! -f "/etc/zsh/zshrc"]; then
        sudo cp ~/.zshrc /etc/zsh/zshrc
    fi

    if [ ! -f "/etc/zsh/dircolors" ]; then
        echo "${CYN}Installing Directory Colors...${NC}"
        sudo cp dotfiles/LS_COLORS /etc/zsh/dircolors
        sudo echo 'test -r /etc/zsh/dircolors && eval "$(dircolors -b /etc/zsh/dircolors)" || eval "$(dircolors -b)"' >> /etc/zsh/zshrc
    fi

    if [ ! -f "/etc/zsh/promptline.sh" ]; then 
        echo "${CYN}Installing Promptline...${NC}"
        sudo cp dotfiles/promptline.sh /etc/zsh/promptline.sh
        sudo echo "source /etc/zsh/promptline.sh" >> /etc/zsh/zshrc
    fi
fi

echo -n "${YEL}Install Essential System Packages (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Essential System Packages...${NC}"
    sudo apt -qq install fonts-firacode fonts-noto git pipenv pax p7zip-rar apt-transport-https ca-certificates isort curl software-properties-common openvpn libssl-dev libffi-dev nfs-common openssh-server -y
fi

echo -n "${YEL}Install Essential Building Packages (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Essential Building Packages...${NC}"
    sudo apt -qq install build-essential make cmake -y
fi

echo -n "Install VIM (y/n)? "
read answer
if [ $answer = "y" ]; then 
    echo "Installing VIM..."
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

echo -n "Install Python3 Libraries (y/n)? "
read answer
if [ $answer = "y" ]; then 
    echo "Installing Python Libraries..."
    sudo apt-get -qq install python3-dev -y
    pip3 install loguru gitpython wpa-supplicant python-wifi rf-info isort flake8 1> /dev/null
fi

echo -n "Install Xubuntu-desktop (y/n)? "
read answer
if [ $answer = "y" ]; then 
    sudo apt -qq install xubuntu-core^ slick-greeter -y
    sudo echo "[SeatDefaults]\ngreeter-session=slick-greeter\n" > /etc/lightdm/lightdm.conf
fi    

echo -n "Install Desktop Apps (y/n)? "
read answer
if [ $answer = "y" ]; then 
    echo "Installing Xfce desktop apps..."
    sudo apt -qq install terminator notepadqq vlc -y
fi    

echo -n "Remove Games (y/n)? "
read answer
if [ $answer = "y" ]; then 
    sudo apt -qq remove sgt-puzzles ristretto *sudoko libgnome-games* gnome-mines -y
fi

echo -n "Remove CUPS Printing (y/n)? "
read answer
if [ $answer = "y" ]; then 
    echo "Removing CUPS Printing..."
    sudo apt -qq remove cups* -y
fi    

echo -n "Remove LibreOffice (y/n)? "
read answer
if [ $answer = "y" ]; then 
    echo "Removing Libreoffice..."
    sudo apt -qq remove libreoffice* -y
fi

echo "Upgrading packages..."
sudo apt -qq full-upgrade -y

echo "Removing un-needed packages..."
sudo apt -qq  autoremove -y

YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

