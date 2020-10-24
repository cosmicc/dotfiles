git clone https://github.com/cosmicc/dotfiles.git
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

echo "Installing zsh shell..."
apt-get -qq install zsh -y
echo "Installing oh-my-zsh"
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp dircolors /etc/zsh/dircolors
cp promptline.sh /etc/zsh/promptline.sh
echo test -r /etc/zsh/dircolors && eval "$(dircolors -b /etc/zsh/dircolors)" || eval "$(dircolors -b)" >> /etc/zsh/zshrc
echo source /etc/zsh/promptline.sh >> /etc/zsh/zshrc
