YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

mkdir /opt/build/radio-tools

echo "${CYN}Installing Prerequisites...${NC}"
sudo apt -qq install libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libqt5quick5 qml-module-qtlocation  qml-module-qtlocation qml-module-qtpositioning qml-module-qtquick-window2 qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qtquick-layouts libqt5serialport5-dev qtdeclarative5-dev qtpositioning5-dev qtlocation5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev doxygen graphviz libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python3-future python3-sip python3-wxgtk4.0 libfltk1.3-dev libpng-dev samplerate-programs libc6 libfltk-images1.3 libfltk1.3 libfltk1.3-dev libgcc1 libhamlib2 libhamlib-dev libpng-dev portaudio19-dev libportaudio2 libportaudiocpp0 libflxmlrpc1v5 libpulse0 libpulse-dev librpc-xml-perl libsamplerate0 libsamplerate0-dev libsndfile1 libsndfile1-dev libstdc++6 libx11-6 libterm-readline-gnu-perl gfortran libfftw3-dev qt5-qmake qtbase5-dev libqt5multimedia5 qtmultimedia5-dev libqt5serialport5 libqt5serialport5-dev qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libvolk2-bin gnuradio gnuradio-dev gr-osmosdr libosmosdr-dev libqt5svg5-dev librtlsdr-dev osmo-sdr portaudio19-dev qt5-default gr-osmosdr gr-gsm pkg-config libglib2.0-dev libgtk-3-dev libgoocanvas-2.0-dev libtool intltool autoconf automake libcurl4-openssl-dev libsigc++-2.0-dev libpopt-dev libspeex-dev libopus-dev libgcrypt20-dev tcl tcl-dev sox libwxbase3.0-dev libwxgtk3.0-gtk3-dev libmotif-dev imagemagick gpsman libspeexdsp-dev openjdk-8-jre ax25-tools ax25-apps soundmodem libliquid2d libtinyxml2.6.2v5 soapysdr-module-all jackd libncurses-dev libboost-dev libboost-date-time-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev libboost-chrono-dev libboost-serialization-dev liblog4cpp5-dev libuhd-dev gnuradio-dev gr-osmosdr libblas-dev liblapack-dev libarmadillo-dev libgflags-dev libgoogle-glog-dev libgnutls-openssl-dev libpcap-dev libmatio-dev libpugixml-dev libgtest-dev libprotobuf-dev protobuf-compiler python3-mako -y

echo -n "${YEL}Install & Setup RPi Hardware Clock (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo i2cdetect -y 1
    echo "${CYN}You should see a UU address.  If you see a 68 address, the RPi config.txt needs the correct overlay driver loaded.${NC}"
    echo -n "${YEL}Do you see the hardware clock UU (y/n)? ${NC}" 
    read answer
    if [ $answer = "y" ]; then
        echo "${CYN}Disabling Pseudo Hardware Clock...${NC}"
        sudo apt-get -y remove fake-hwclock
        sudo update-rc.d -f fake-hwclock remove
        sudo systemctl disable fake-hwclock
        echo -n "${CYN}Current Hardware Clock Value: ${NC}"
        sudo hwclock -D -r
        echo -n "${CYN}Current System Clock Value: ${NC}"
        date
        echo -n "${YEL}Do you want to set the hardware clock to the system time (y/n)? ${NC}"
        read answer
        if [ $answer = "y" ]; then
            sudo hwclock -w
        fi
        sudo cp templates/hwclock-set /usr/lib/udev/hwclock-set -f
    else
        echo "${CYN}Fix Hardware clock connection and try again after.${NC}"
    fi
fi

echo -n "${YEL}Install & Setup GPSd (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo apt -qq install minicom gpsd gpsd-clients -y
    
    
fi

echo -n "${YEL}Download & Install Chirp (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing Chirp...${NC}"
    sudo apt -qq install chirp -y
fi

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
    echo "${CYN}Compiling & Installing JS8Call...${NC}"
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
    echo "${CYN}Compiling & Installing GQRX...${NC}"
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
    echo "${CYN}Compiling & Installing Dump1090...${NC}"
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
    echo "${CYN}Compiling & Installing GPredict...${NC}"
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

echo -n "${YEL}Download, Compile & Install QTel (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then 
    echo "${CYN}Installing QTel...${NC}"
    cd /opt/build/radio-tools
    if [ ! -d "/opt/build/radio-tools/svxlink" ]; then
        echo "${CYN}Cloning QTel Source...${NC}"
        git clone https://github.com/sm0svx/svxlink.git
        cd svxlink/src
        mkdir build
        cd build
    else
        echo "${CYN}Updating QTel Source...${NC}"
        cd svxlink/src/build
        make clean
        git pull
    fi
    echo "${CYN}Compiling & Installing QTel...${NC}"
    cmake ../
    make
    sudo make install
fi

echo -n "${YEL}Download, Compile & Install FreeDV (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing FreeDV...${NC}"
    if [ ! -d "/opt/build/radio-tools/freedv-gui" ]; then
        echo "${CYN}Cloning FreeDV Source...${NC}"
        git clone https://github.com/drowe67/freedv-gui.git
        cd freedv-gui
    else
        echo "${CYN}Updating FreeDV Source...${NC}"
        cd freedv-gui
        git pull
    fi
    echo "${CYN}Compiling & Installing FreeDV...${NC}"
    sh build_linux.sh
    cd build_linux
    sudo make install
fi

echo -n "${YEL}Download, Compile & Install VOACAP (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing VOACAP...${NC}"
    cd /opt/build/radio-tools
    if [ ! -d "/opt/build/radio-tools/voacapl" ]; then
        echo "${CYN}Cloning VOACAP Source...${NC}"
        git clone https://github.com/jawatson/voacapl.git
        cd voacapl
    else
        echo "${CYN}Updating VOACAP Source...${NC}"
        cd voacapl
        make clean
        git pull
    fi
    echo "${CYN}Compiling & Installing VOACAP...${NC}"
    ./configure
    aclocal
    automake
    make
    sudo make install
    sudo makeitshfbc
fi    

echo -n "${YEL}Download, Compile & Install Xastir (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing Xastir...${NC}"
    if [ ! -d "/opt/build/radio-tools/Xastir" ]; then
        echo "${CYN}Cloning Xastir Source...${NC}"
        git clone https://github.com/Xastir/Xastir.git
        cd Xastir
    else
        echo "${CYN}Updating Xastir Source...${NC}"
        cd Xastir
        git pull
    fi
    echo "${CYN}Compiling & Installing Xastir...${NC}"
    ./update-xastir
    cd build
    sudo make install 
fi

echo -n "${YEL}Download, Compile & Install YAAC (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing YAAC...${NC}"
    if [ ! -d "/opt/build/radio-tools/Xastir" ]; then
        echo "${CYN}Cloning YAAC Source...${NC}"
        git clone https://github.com/Xastir/Xastir.git
        cd Xastir
    else
        echo "${CYN}Updating YAAC Source...${NC}"
        cd Xastir
        git pull
    fi
    echo "${CYN}Compiling & Installing YAAC...${NC}"
    ./update-xastir
    cd build
    sudo make install 
fi

echo -n "${YEL}Download, Compile & Install YAAC (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing YAAC...${NC}"
    if [ -d "/opt/build/radio-tools/yaac" ]; then
        rm -r yaac
    fi
    mkdir yaac
    cd yaac
    wget -r -nd --no-parent -A '*.tmp' https://sourceforge.net/projects/yetanotheraprsc/files/latest/download
    mv download.tmp yaac.zip
    unzip yaac.zip
    rm yaac.zip
    sudo sh -c 'echo "java -jar /opt/build/radio-tools/yaac/YAAC.jar" > /usr/local/bin/yaac'
    sudo chmod ugo+rx /usr/local/bin/yaac
fi

echo -n "${YEL}Download, Compile & Install Direwolf (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing Direwolf...${NC}"
    if [ ! -d "/opt/build/radio-tools/direwolf" ]; then
        echo "${CYN}Cloning Direwolf Source...${NC}"
        git clone https://github.com/wb2osz/direwolf.git
        cd direwolf
        echo "${CYN}Compiling & Installing Direwolf...${NC}"
        make
        sudo make install
        make install-conf
    else
        echo "${CYN}Updating Direwolf Source...${NC}"
        cd direwolf
        make clean
        git pull
        echo "${CYN}Compiling & Installing Direwolf...${NC}"
        make
        sudo make install
    fi
fi

echo -n "${YEL}Install APRX Package (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo apt -qq install aprx -y
fi

echo -n "${YEL}Install APRSDigi Package (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo apt -qq install aprsdigi -y
fi

echo -n "${YEL}Install CubicSDR Package (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo apt -qq install cubicsdr -y
fi

echo -n "${YEL}Install CuteSDR Package (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    sudo apt -qq install cutesdr -y
fi

echo -n "${YEL}Download, Compile & Install Lysdr (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    mkdir /opt/build/radio-tools
    echo "${CYN}Installing Lysdr...${NC}"
    if [ ! -d "/opt/build/radio-tools/lysdr" ]; then
        echo "${CYN}Cloning Lysdr Source...${NC}"
        git clone https://github.com/gordonjcp/lysdr.git
        cd lysdr
        echo "${CYN}Compiling & Installing Lysdr...${NC}"
        ./autogen.sh
        ./configure
        make
    else
        echo "${CYN}Updating Lysdr Source...${NC}"
        cd lysdr
        make clean
        git pull
        echo "${CYN}Compiling & Installing Lysdr...${NC}"
        ./autogen.sh
        ./configure
        make -j4
        sudo make install
    fi
fi

echo -n "${YEL}Download & Install Quisk (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    cd /opt/build/radio-tools
    echo "${CYN}Installing Quisk...${NC}"
    sudo -H python3 -m pip install --upgrade quisk
fi

echo -n "${YEL}Download, Compile & Install twpsk (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing twpsk...${NC}"
    cd /opt/build/radio-tools
    wget http://wa0eir.bcts.info/src/twpsk-4.3.src.tar.gz
    tar xvfz twpsk*.src.tar.gz
    rm twpsk*.src.tar.gz
    cd twpsk*
    ./configure
    make -j4
    make install
fi

echo -n "${YEL}Download, Compile & Install psk31lx (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing psk31lx...${NC}"
    cd /opt/build/radio-tools
    wget http://wa0eir.bcts.info/src/psk31lx-2.2.src.tar.gz
    tar xvfz psk31lx*.src.tar.gz
    rm psk31lx*.src.tar.gz
    cd psk31lx*
    ./configure
    make -j4
    make install
fi

echo -n "${YEL}Download, Compile & Install Multimon-ng (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    mkdir /opt/build/radio-tools
    echo "${CYN}Installing Multimon-ng...${NC}"
    if [ ! -d "/opt/build/radio-tools/lysdr" ]; then
        echo "${CYN}Cloning Multimon-ng Source...${NC}"
        git clone https://github.com/gordonjcp/lysdr.git
        cd multimon-ng
        mkdir build
        cd build
    else
        echo "${CYN}Updating Multimon-ng Source...${NC}"
        cd multimon-ng
        make clean
        git pull
        cd build
        make clean
    fi
        echo "${CYN}Compiling & Installing Multimon-ng...${NC}"
        cmake ..
        make -j4
        sudo make install
fi

echo -n "${YEL}Download, Compile & Install GNSS-SDR (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    mkdir /opt/build/radio-tools
    echo "${CYN}Installing GNSS-SDR...${NC}"
    if [ ! -d "/opt/build/radio-tools/gnss-sdr" ]; then
        echo "${CYN}Cloning GNSS-SDR Source...${NC}"
        git clone https://github.com/gnss-sdr/gnss-sdr.git
        cd gnss-sdr
        cd build
    else
        echo "${CYN}Updating GNSS-SDR Source...${NC}"
        cd gnss-sdr
        make clean
        git pull
        cd build
        make clean
    fi
        echo "${CYN}Compiling & Installing GNSS-SDR...${NC}"
        cmake ..
        make -j4
        sudo make install
fi

