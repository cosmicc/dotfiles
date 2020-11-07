#!/bin/env sh

YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

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
    
swapon -s    
echo -n "${YEL}Configure Swap Space (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Creating A Swapfile ...${NC}"
    sudo fallocate -l 4G /swapfile
    sudo dd if=/dev/zero of=/swapfile bs=1024 count=4194304
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    echo "${CYN}Activating Swapfile ...${NC}"
    sudo swapon /swapfile
    sudo sysctl vm.swappiness=10
    sudo sh -c 'echo "vm.swappiness=10" >> /etc/sysctl.conf'
    sudo sh -c 'echo "/swapfile swap swap defaults 0 0" >> /etc/fstab'
fi

echo -n "${YEL}Add New Admin User (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Adding New User...${NC}"
    echo -n "${YEL}Type new username: ${NC}"; read username
    sudo adduser $username
    sudo usermod -aG sudo $username
    cd /home/$username
    sudo wget https://raw.githubusercontent.com/cosmicc/dotfiles/main/install2.sh
    sudo chmod ugo+rwx install2.sh
    echo "${YEL}Type sh install2.sh${NC}"
    sudo su $username
else
    sudo wget https://raw.githubusercontent.com/cosmicc/dotfiles/main/install2.sh
    sh install2.sh
fi    
    
