YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

echo "${CYN}Installing Prerequisites...${NC}"
sudo apt -qq install libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python3-future python3-sip python3-wxgtk4.0 libfltk1.3-dev libpng-dev samplerate-programs libc6 libfltk-images1.3 libfltk1.3 libfltk1.3-dev libgcc1 libhamlib2 libhamlib-dev libpng-dev portaudio19-dev libportaudio2 libportaudiocpp0 libflxmlrpc1v5 libpulse0 libpulse-dev librpc-xml-perl libsamplerate0 libsamplerate0-dev libsndfile1 libsndfile1-dev libstdc++6 libx11-6 libterm-readline-gnu-perl gfortran libfftw3-dev qt5-qmake qtbase5-dev libqt5multimedia5 qtmultimedia5-dev libqt5serialport5 libqt5serialport5-dev qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libvolk2-bin gnuradio gnuradio-dev gr-osmosdr libosmosdr-dev libqt5svg5-dev librtlsdr-dev osmo-sdr portaudio19-dev qt5-default -y

echo "${CYN}Installing Chirp...${NC}"
sudo apt -qq install chirp -y

echo -n "${YEL}Download, Compile & Install Fldigi Suite (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Fldigi...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/fldigi/
    ls -tQ fldigi*.tar.gz | tail -n+2 | xargs rm
    tar xbfz fldigi*.tar.gz
    rm fldigi*.tar.gz
    cd fldigi-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/fldigi/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flrig...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flrig/
    ls -tQ flrig*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flrig*.tar.gz
    rm flrig*.tar.gz
    cd flrig-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flrig/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flmsg...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flmsg/
    ls -tQ flmsg*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flmsg*.tar.gz
    rm flmsg*.tar.gz
    cd flmsg-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flmsg/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flamp...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flamp/
    ls -tQ flamp*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flamp*.tar.gz
    rm flamp*.tar.gz
    cd flamp-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flamp/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools
    
    echo "${CYN}Installing Fllog...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/fllog/
    ls -tQ fllog*.tar.gz | tail -n+2 | xargs rm
    tar xbfz fllog*.tar.gz
    rm fllog*.tar.gz
    cd fllog-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/fllog/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools
    
    echo "${CYN}Installing Flnet...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flnet/
    ls -tQ flnet*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flnet*.tar.gz
    rm flnet*.tar.gz
    cd flnet-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flnet/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flwkey...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flwkey/
    ls -tQ flwkey*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flwkey*.tar.gz
    rm flwkey*.tar.gz
    cd flwkey-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flwkey/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flwrap...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flwrap/
    ls -tQ flwrap*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flwrap*.tar.gz
    rm flwrap*.tar.gz
    cd flwrap-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flwrap/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flcluster...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flcluster/
    ls -tQ flcluster*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flcluster*.tar.gz
    rm flcluster*.tar.gz
    cd flcluster-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flcluster/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools

    echo "${CYN}Installing Flaa...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/flaa/
    ls -tQ flaa*.tar.gz | tail -n+2 | xargs rm
    tar xbfz flaa*.tar.gz
    rm flaa*.tar.gz
    cd flaa-*
    wget -r -nd --no-parent -A '*.pdf' http://www.w1hkj.com/files/flaa/
    ./configure
    make -j4
    sudo make install
    cd /opt/build/radio-tools
fi

echo -n "${YEL}Download, Compile & Install JS8Call (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing JS8Call...${NC}"
    cd /opt/build/radio-tools
    git clone https://widefido@bitbucket.org/widefido/js8ca/usr/lib/aarch64-linux-gnull.git
    mkdir build
    cd build
    cmake -Dhamlib_LIBRARY_DIRS=/usr/lib/aarch64-linux-gnu -DJS8_USE_HAMLIB_THREE=1 ../
    make
fi

echo -n "${YEL}Download, Compile & Install GQRX (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing GQRX...${NC}"
    cd /opt/build/radio-tools
    wget https://github.com/csete/gqrx/releases/download/v2.11.5/gqrx-sdr-2.11.5-src.tar.xz
    xz --decompress gqrx*.xz
    tar xvf gqrx*.tar
    rm gqrx*.tar
    cd gqrx*
    mkdir build
    cd build
    cmake ../
fi







