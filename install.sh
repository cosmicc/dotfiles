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
    install2.sh
fi    
    
