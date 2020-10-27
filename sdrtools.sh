YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

mkdir /opt/build/radio-tools

echo "${CYN}Installing Prerequisites...${NC}"
sudo apt -qq install libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python3-future python3-sip python3-wxgtk4.0 libfltk1.3-dev libpng-dev samplerate-programs libc6 libfltk-images1.3 libfltk1.3 libfltk1.3-dev libgcc1 libhamlib2 libhamlib-dev libpng-dev portaudio19-dev libportaudio2 libportaudiocpp0 libflxmlrpc1v5 libpulse0 libpulse-dev librpc-xml-perl libsamplerate0 libsamplerate0-dev libsndfile1 libsndfile1-dev libstdc++6 libx11-6 libterm-readline-gnu-perl gfortran libfftw3-dev qt5-qmake qtbase5-dev libqt5multimedia5 qtmultimedia5-dev libqt5serialport5 libqt5serialport5-dev qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libvolk2-bin gnuradio gnuradio-dev gr-osmosdr libosmosdr-dev libqt5svg5-dev librtlsdr-dev osmo-sdr portaudio19-dev qt5-default gr-osmosdr gr-gsm pkg-config libglib2.0-dev libgtk-3-dev libgoocanvas-2.0-dev libtool intltool autoconf automake libcurl4-openssl-dev -y

echo "${CYN}Installing Chirp...${NC}"
sudo apt -qq install chirp -y

echo -n "${YEL}Download, Compile & Install Fldigi Suite (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Fldigi...${NC}"
    cd /opt/build/radio-tools
    wget -r -nd --no-parent -A '*.tar.gz' http://www.w1hkj.com/files/fldigi/
    ls -tQ fldigi*.tar.gz | tail -n+2 | xargs rm
    tar xfz fldigi*.tar.gz
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
    tar xfz flrig*.tar.gz
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
    tar xfz flmsg*.tar.gz
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
    tar xfz flamp*.tar.gz
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
    tar xfz fllog*.tar.gz
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
    tar xfz flnet*.tar.gz
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
    tar xfz flwkey*.tar.gz
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
    tar xfz flwrap*.tar.gz
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
    tar xfz flcluster*.tar.gz
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
    tar xfz flaa*.tar.gz
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
    if [ ! -d "/opt/build/radio-tools/js8call" ]; then
        echo "${CYN}Cloning JS8Call Source...${NC}"
        git clone https://widefido@bitbucket.org/widefido/js8ca/usr/lib/aarch64-linux-gnull.git
    else
        echo "${CYN}Updaing JS8Call Source...${NC}"
        cd js8call
        git pull
    fi
    mkdir build
    cd build
    cmake -Dhamlib_LIBRARY_DIRS=/usr/lib/aarch64-linux-gnu -DJS8_USE_HAMLIB_THREE=1 ../
    sed -i '1s/^/#define JS8_USE_HAMLIB_THREE\n /' /opt/build/radio-tools/js8call/HamlibTransceiver.hpp
    make
    sudo make install
    echo "${CYN}Installing JS8Call Utilities...${NC}"
    cd /opt/build/radio-tools
    git clone https://github.com/m0iax/JS8CallUtilities_V2.git
fi

echo -n "${YEL}Download, Compile & Install GQRX (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing GQRX...${NC}"
    cd /opt/build/radio-tools
    if [ ! -d "/opt/build/radio-tools/gqrx" ]; then
        echo "${CYN}Cloning GQRX Source...${NC}"
        git clone https://github.com/csete/gqrx.git
        cd gqrx
    else
        echo "${CYN}Updaing GQRX Source...${NC}"
        cd gqrx
        rm -r build
        git pull
    fi
    mkdir build
    cd build
    cmake ../
    make
    sudo make install
fi

echo -n "${YEL}Download, Compile & Install Dump1090 (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Dump1090...${NC}"
    cd /opt/build/radio-tools
    if [ ! -d "/opt/build/radio-tools/dump1090" ]; then
        echo "${CYN}Cloning Dump1090 Source...${NC}"
        git clone https://github.com/antirez/dump1090.git
        cd dump1090
    else
        echo "${CYN}Updaing Dump1090 Source...${NC}"
        cd dump1090
        sudo rm dump1090 -f
        make clean
        git pull
    fi
    make
    sudo cp dump1090 /usr/local/bin -f
    sudo chmod ugo+x /usr/local/bin/dump1090
fi

echo -n "${YEL}Download, Compile & Install VirtualFlight Radar (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing VirtualFlight Prerequisites...${NC}"
    sudo apt -qq install mono-complete -y
    echo "${CYN}Installing VirtualFlight Radar...${NC}"
    cd /opt/build/radio-tools
    wget http://www.virtualradarserver.co.uk/Files/VirtualRadar.tar.gz
    rm -r virtualradar
    mkdir virtualradar
    tar xvfz VirtualRadar.tar.gz -C virtualradar
    rm VirtualRadar.tar.gz
    cd virtualradar
    
fi

echo -n "${YEL}Download, Compile & Install GPredict (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing GPredict...${NC}"
    cd /opt/build/radio-tools
    if [ ! -d "/opt/build/radio-tools/gpredict" ]; then
        echo "${CYN}Cloning GPredict Source...${NC}"
        git clone https://github.com/csete/gpredict.git
        cd gpredict
    else    
        echo "${CYN}Updating GPredict Source...${NC}"
        cd gpredict
        git pull
        make clean
    fi
    ./autogen.sh
    make
    sudo make install
fi



echo -n "${YEL}Download, Compile & Install GRIG (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing GRIG Prerequisites...${NC}"
    sudo apt -qq install gtk+2.0 -f
    echo "${CYN}Installing GRIG...${NC}"
    cd /opt/build/radio-tools
    wget https://sourceforge.net/projects/groundstation/files/Grig/0.8.1/grig-0.8.1.tar.gz
    tar xvfz grig*.tar.gz
    rm grig.tar.gz -f
    cd grig*
fi

