print_debug() {
	  echo "$1"
  }

print_info() {
	  echo -e "\033[33m$1\033[0m"
  }

print_noop() {
	  echo -e "\033[35m$1\033[0m"
  }

print_success() {
	  echo -e "\033[32m$1\033[0m"
  }

print_error() {
	  echo -e "\033[31m$1\033[0m"
  }

die() {
	  echo $1
	    exit ${2:-1}
    }

echo "Updating packages..."
sudo apt-get -qq update -y

echo "Cloning Dotfiles..."
git clone https://github.com/cosmicc/dotfiles.git 1> /dev/null

read -p "Install ZSH Shell (y/n)? " answer
if [ $answer = "y" ]; then
    echo "Installing ZSH Shell..."
    sudo apt-get -qq install zsh -y

    echo "Installing oh-my-zsh"
    wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O zmginstall.sh 1> /dev/null
    sh ./zmginstall.sh
    rm ./zmginstall.sh -f

    if [ ! -f "/etc/zsh/dircolors" ]; then
        echo "Installing Directory Colors..."
        sudo cp dotfiles/LS_COLORS /etc/zsh/dircolors
        sudo echo 'test -r /etc/zsh/dircolors && eval "$(dircolors -b /etc/zsh/dircolors)" || eval "$(dircolors -b)"' >> /etc/zsh/zshrc
    fi

    if [ ! -f "/etc/zsh/promptline.sh" ]; then 
        echo "Installing Promptline..."
        sudo cp dotfiles/promptline.sh /etc/zsh/promptline.sh
        echo "source /etc/zsh/promptline.sh" >> /etc/zsh/zshrc
    fi
fi

read -p "Install Essential System Packages (y/n)? " answer      
if [ $answer = "y" ]; then 
    sudo apt -qq install fonts-firacode fonts-noto git pipenv pax p7zip-rar apt-transport-https ca-certificates curl software-properties-common openvpn libssl-dev libffi-dev nfs-common -y
fi

read -p "Install Essential Building Packages (y/n)? " answer      
if [ $answer = "y" ]; then 
    sudo apt -qq install build-essential make cmake -y
fi

read -p "Install VIM (y/n)? " answer      
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

read -p "Install Python3 Libraries (y/n)? " answer      
if [ $answer = "y" ]; then 
    echo "Installing Python Libraries..."
    sudo apt-get -qq install python3-dev -y
    pip3 install loguru gitpython wpa-supplicant python-wifi rf-info 1> /dev/null
fi

read -p "Install Xubuntu-desktop (y/n)? " answer      
if [ $answer = "y" ]; then 
    sudo apt -qq install xubuntu-desktop -y
fi    

read -p "Install Desktop Apps (y/n)? " answer      
if [ $answer = "y" ]; then 
    echo "Installing Xfce desktop apps..."
    sudo apt -qq install terminator notepadqq vlc -y
fi    

read -p "Remove Games (y/n)? " answer      
if [ $answer = "y" ]; then 
    echo "Removing Games..."
    sudo apt -qq remove sgt-puzzles ristretto *sudoko libgnome-games* gnome-mines -y
fi

read -p "Remove CUPS Printing (y/n)? " answer      
if [ $answer = "y" ]; then 
    echo "Removing CUPS Printing..."
    sudo apt -qq remove cups* -y
fi    

read -p "Remove LibreOffice (y/n)? " answer      
if [ $answer = "y" ]; then 
    echo "Removing Libreoffice..."
    sudo apt -qq remove libreoffice* -y
fi

echo "Upgrading packages..."
sudo apt -qq full-upgrade -y

echo "Removing un-needed packages..."
sudo apt -qq  autoremove -y

