YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

echo "${CYN}Installing Prerequisites...${NC}"
sudo apt -qq install libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python3-future python3-sip python3-wxgtk4.0 libfltk1.3-dev libpng-dev samplerate-programs libc6 libfltk-images1.3 libfltk1.3 libfltk1.3-dev libgcc1 libhamlib2 libhamlib-dev libpng-dev portaudio19-dev libportaudio2 libportaudiocpp0 libflxmlrpc1v5 libpulse0 libpulse-dev librpc-xml-perl libsamplerate0 libsamplerate0-dev libsndfile1 libsndfile1-dev libstdc++6 libx11-6 libterm-readline-gnu-perl -y

echo "${CYN}Installing Chirp...${NC}"
sudo apt -qq install chirp -y

echo "${CYN}Installing Fldigi...${NC}"

cd /opt/build/radio-tools
wget http://www.w1hkj.com/files/fldigi/fldigi*.tar.gz
tar xbfz fldigi*.tar.gz
./configure
make -j4
sudo make install






