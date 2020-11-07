#!/bin/env sh

YEL='\033[1;33m'
GRN='\033[1;32m'
CYN='\033[1;36m'
MGT='\033[1;35m'
NC='\033[0m'

radiodir=/opt/build/radioapps
logdir=/opt/logs/
logfile=/opt/logs/sdrtools.log
attempts=5

# compare files
comp_files () {
    file1=`md5sum $1`
    file2=`md5sum $2`
    file3=`echo $file2 | sed -r 's/(.{32}).*/\1/'`
    file4=`echo $file1 | sed -r 's/(.{32}).*/\1/'`
    if [ $file3 = $file4 ]; then
        return 58
    else
        return 21
    fi
}


# check_update /dir giturl
check_update () {
    echo -n "${CYN}Checking for $3 Updates "
    if [ -d $1 ]; then
        cd $1
        LOCAL=`git rev-parse HEAD`
        REMOTE=`git ls-remote | grep HEAD`
        LOCAL2="${LOCAL##*$'\n'}"
        REMOTE2=`echo $REMOTE | cut -d' ' -f 1` 
        if [ $LOCAL2 = $REMOTE2 ]; then
            echo "${CYN}No Updates Available.${NC}"
            return 58
        else
            echo "${YEL}New Version Available! Downloading...${NC}"
            git pull >> $logfile 2>&1 
            if [ -d $1/build ]; then
                sudo rm -rf $1/build
            fi
            return 21
        fi
    else
        echo "${YEL}$3 Does Not Exist! Downloading...${NC}"
        mkdir -p $1
        git clone $2 $1 >> $logfile 2>&1
        cd $1
        git config pull.rebase false
        return 21 
    fi
}

echo "${YEL}Starting Amateur Radio Application Installer!${NC}"

if [ ! -d $radiodir ]; then
    echo "${MGT}Radioapps Directory doesn't exist, creating.${NC}"
    mkdir -p $radiodir
fi

if [ ! -d /opt/downloads ]; then
    echo "${MGT}Downloads Directory doesn't exist, creating.${NC}"
    mkdir -p /opt/downloads
fi

if [ ! -d $logdir ]; then
    echo "${MGT}Log Directory doesn't exist, creating.${NC}"
    mkdir -p $logdir 
fi

sudo chown sdr.sdr /opt/build -R
touch $logfile

count=1
echo "${CYN}Updating OS Packages (Attempt #$count)...${NC}"
while [ $count -le $attempts ]; do
    sudo sh -c "apt -qq update -y > $logfile 2>&1"
    if [ $? -ne 0 ]; then
        ((count=count+1))
    else
        count=99
    fi
done

count=1
echo "${CYN}Verifying & Installing Prerequisites (Attempt #$count)...${NC}"
while [ $count -le $attempts ]; do
    sudo sh -c "apt -qq install libfftw3-dev libusb-1.0-0-dev libusb-dev qt5-default qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev qtbase5-dev libqt5quick5 qml-module-qtlocation  qml-module-qtlocation qml-module-qtpositioning qml-module-qtquick-window2 qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qtquick-layouts libqt5serialport5-dev qtdeclarative5-dev qtpositioning5-dev qtlocation5-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex ffmpeg libavcodec-dev libavformat-dev libopus-dev doxygen graphviz libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python3-future python3-sip python3-wxgtk4.0 libfltk1.3-dev libpng-dev samplerate-programs libc6 libfltk-images1.3 libfltk1.3 libfltk1.3-dev libgcc1 libhamlib2 libhamlib-dev libpng-dev portaudio19-dev libportaudio2 libportaudiocpp0 libflxmlrpc1v5 libpulse0 libpulse-dev librpc-xml-perl libsamplerate0 libsamplerate0-dev libsndfile1 libsndfile1-dev libstdc++6 libx11-6 libterm-readline-gnu-perl gfortran libfftw3-dev qt5-qmake qtbase5-dev libqt5multimedia5 qtmultimedia5-dev libqt5serialport5 libqt5serialport5-dev qt5-default qtscript5-dev libssl-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5webkit5-dev libsdl2-dev libasound2 libxmu-dev libxi-dev freeglut3-dev libasound2-dev libjack-jackd2-dev libxrandr-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libvolk2-bin gnuradio gnuradio-dev gr-osmosdr libosmosdr-dev libqt5svg5-dev librtlsdr-dev osmo-sdr portaudio19-dev qt5-default gr-osmosdr gr-gsm pkg-config libglib2.0-dev libgtk-3-dev libgoocanvas-2.0-dev libtool intltool autoconf automake libcurl4-openssl-dev libsigc++-2.0-dev libpopt-dev libspeex-dev libopus-dev libgcrypt20-dev tcl tcl-dev sox libwxbase3.0-dev libwxgtk3.0-gtk3-dev libmotif-dev imagemagick gpsman libspeexdsp-dev openjdk-8-jre ax25-tools ax25-apps soundmodem libliquid2d libtinyxml2.6.2v5 soapysdr-module-all jackd libncurses-dev libboost-dev libboost-date-time-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev libboost-chrono-dev libboost-serialization-dev liblog4cpp5-dev libuhd-dev gnuradio-dev gr-osmosdr libblas-dev liblapack-dev libarmadillo-dev libgflags-dev libgoogle-glog-dev libgnutls-openssl-dev libpcap-dev libmatio-dev libpugixml-dev libgtest-dev libprotobuf-dev protobuf-compiler python3-mako libwxgtk-webview3.0-gtk3-dev libgtk-3-dev libbz2-dev exif libarchive-dev libsndfile1-dev portaudio19-dev gettext sqlite3 libsqlite3-dev libcurl4-openssl-dev libtinyxml-dev libexif-dev liblzma-dev liblz4-dev libao-dev i2c-tools asciidoctor subversion texinfo asciidoc-base libjsoncpp-dev -y"
    if [ $? -ne 0 ]; then
        ((count=count+1))
    else
        count=99
    fi
done

count=1
echo "${CYN}Upgrading OS Packages (Attempt #$count)...${NC}"
while [ $count -lt $attempts ]; do
    sudo sh -c "apt -qq upgrade -y >> $logfile 2>&1"
    if [ $? -ne 0 ]; then
        ((count=count+1))
    else
        count=99
    fi
done

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
        sudo cp /opt/rpisetup/templates/hwclock-set /usr/lib/udev/hwclock-set -f
	sudo cp /opt/rpisetup/templates/dtime /usr/local/bin -f
	sudo cp /opt/rpisetup/templates/dhclient.conf /etc/dhcp -f
    else
        echo "${CYN}Fix Hardware clock connection and try again after.${NC}"
    fi
fi

echo -n "${YEL}Install & Configure GPSd (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing & Configuring GPSd...${NC}"
    sudo sh -c "apt -qq install minicom gpsd gpsd-clients -y >> $logfile 2>&1"
    sudo cp /opt/rpisetup/templates/gpsd /etc/default/gpsd -f
    sudo systemctl restart gpsd
fi

echo -n "${YEL}Install & Setup NTPd (y/n)? ${NC}"
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing & Configuring NTPd...${NC}"
    sudo sh -c "apt -qq install ntp pps-tools -y >> $logfile 2>&1"
    sudo sh -c 'echo "pps-gpio" > /etc/modules'
    sudo cp /opt/rpisetup/templates/ntp.conf /etc/ntp.conf -f
    sudo systemctl restart ntp
fi

appname=wsjtx
touch $logdir$appname.log
cd $radiodir
echo "${CYN}$appname Updates here: ${YEL}http://physics.princeton.edu/pulsar/K1JT/wsjtx.html${NC}"
if [ ! -f /opt/downloads/wsjtx.tgz ]; then
    echo "${CYN}Checking For $appname Updates...${NC}"	
    wget http://physics.princeton.edu/pulsar/K1JT/wsjtx-2.3.0-rc1.tgz -O $radiodir/wsjtx.tgz >> $logdir$appname.log 2>&1
else
    echo -n "${YEL}Paste wget URL for new $appname Version (or n): ${NC}"
    read answer
    if [ $answer = "n" ]; then
        echo "${CYN}Cancelled $appname Update${NC}"
    else
	echo "${CYN}Checking For $appname Updates...${NC}"
        wget $answer -O $radiodir/wsjtx.tgz >> $logdir$appname.log 2>&1	    
    fi
fi
if [ -f /opt/downloads/wsjtx.tgz ]; then
    comp_files $radiodir/wsjtx.tgz /opt/downloads/wsjtx.tgz
    if [ $? = 58 ]; then
        echo "${CYN}$appname Has no Updates Available...${NC}"
        rm -f $radiodir/wsjtx.tgz
        INST=0
    else
        echo "${CYN}$appname New Version Available!${NC}"
        mv -f $radiodir/wsjtx.tgz /opt/downloads
        INST=1
    fi    
else
    mv -f $radiodir/wsjtx.tgz /opt/downloads
    INST=1
fi    
if [ $INST -eq 1 ]; then
    # Install Start
    echo "${CYN}Unpacking $appname...${NC}"
    tar xvfz /opt/downloads/wsjtx.tgz -C $radiodir >> $logdir$appname.log 2>&1
    echo "${CYN}Preparing $appname...${NC}"
    cd $radiodir/wsjtx*
    mkdir build
    cd build
    cmake .. >> $logdir$appname.log 2>&1
    echo "${CYN}Compiling $appname...${NC}"
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=js8call
check_update $radiodir/$appname https://widefido@bitbucket.org/widefido/js8call.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir build
    cd build
    cmake -Dhamlib_LIBRARY_DIRS=/usr/lib/aarch64-linux-gnu -DJS8_USE_HAMLIB_THREE=1 ../ >> $logdir$appname.log 2>&1 
    sed -i '1s/^/#define JS8_USE_HAMLIB_THREE\n /' $radiodir/js8call/HamlibTransceiver.hpp
    echo "${CYN}Compiling $appname...${NC}"
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=js8call_utilities
check_update $radiodir/$appname https://github.com/m0iax/JS8CallUtilities_V2.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Installing $appname...${NC}"
    # Install Start
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else
        echo "${GRN}$appname Install Complete!${NC}"
    fi    
fi

appname=gqrx
check_update $radiodir/$appname https://github.com/csete/gqrx.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir build
    cd build
    cmake ../ >> $logdir$appname.log 2>&1 
    echo "${CYN}Compiling $appname...${NC}"
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=dump1090
check_update $radiodir/$appname https://github.com/antirez/dump1090.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo cp dump1090 /usr/local/bin -f
    sudo chmod ugo+x /usr/local/bin/dump1090
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
    fi    
fi

appname=opencpn
check_update $radiodir/$appname https://github.com/OpenCPN/OpenCPN.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir build
    cd build
    cmake ../ >> $logdir$appname.log 2>&1 
    echo "${CYN}Compiling $appname...${NC}"
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=rtl_ais
check_update $radiodir/$appname https://github.com/dgiardini/rtl-ais.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=nrsc5 # Digital Radio Tuner
check_update $radiodir/$appname https://github.com/theori-io/nrsc5.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir build
    cd build
    cmake -DUSE_NEON=ON ../ >> $logdir$appname.log 2>&1 
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=gpredict # Satellite Tracking
check_update $radiodir/$appname https://github.com/csete/gpredict.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    ./autogen.sh >> $logdir$appname.log 2>&1
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=virtualradar # Flight Tracking
echo "${CYN}Installing $appname Prerequisites...${NC}"
touch $logdir$appname.log
sudo sh -c "apt -qq install mono-complete -y >> $logdir$appname.log 2>&1"
echo "${CYN}Checking For $appname Updates...${NC}"
cd $radiodir
wget http://www.virtualradarserver.co.uk/Files/VirtualRadar.tar.gz >> $logdir$appname.log 2>&1
if [ -f /opt/downloads/VirtualRadar.tar.gz ]; then
    comp_files $radiodir/VirtualRadar.tar.gz /opt/downloads/VirtualRadar.tar.gz
    if [ $? = 58 ]; then
        echo "${CYN}$appname Has no Updates Available...${NC}"
        rm -f $radiodir/VirtualRadar.tar.gz
        INST=0
    else
        echo "${CYN}$appname New Version Available!${NC}"
        mv -f $radiodir/VirtualRadar.tar.gz /opt/downloads
        INST=1
    fi    
else
    mv -f $radiodir/VirtualRadar.tar.gz /opt/downloads
    INST=1
fi    
if [ $INST -eq 1 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Unpacking $appname...${NC}"
    mkdir $radiodir/$appname
    tar xvfz /opt/dowloads/VirtualRadar.tar.gz -C $radiodir/$appname >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    ################################
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=qtel
check_update $radiodir/$appname https://github.com/sm0svx/svxlink.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir -p src/build
    cd src/build
    cmake ../ >> $logdir$appname.log 2>&1 
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "adduser --system --home=/dev/null --no-create-home --group svxlink >> $logdir$appname.log 2>&1"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=freedv
check_update $radiodir/$appname https://github.com/drowe67/freedv-gui.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    sh build_linux.sh >> $logdir$appname.log 2>&1
    cd build_linux
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=voacap
check_update $radiodir/$appname https://github.com/jawatson/voacapl.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    ./configure  >> $logdir$appname.log 2>&1
    echo "${CYN}Compiling $appname...${NC}"
    aclocal >> $logdir$appname.log 2>&1
    automake >> $logdir$appname.log 2>&1
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "makeitshfbc >> $logdir$appname.log 2>&1"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=xastir
check_update $radiodir/$appname https://github.com/Xastir/Xastir.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    rm -r build
    ./update-xastir >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    cd build
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=yaac # 
echo "${CYN}Checking For $appname Updates...${NC}"
cd $radiodir
wget -r -nd --no-parent -A '*.tmp' https://sourceforge.net/projects/yetanotheraprsc/files/latest/download >> $logdir$appname.log 2>&1
if [ -f /opt/downloads/yaac.zip ]; then
    comp_files $radiodir/download.tmp /opt/downloads/yaac.zip
    if [ $? = 58 ]; then
        echo "${CYN}$appname Has no Updates Available...${NC}"
        rm -f $radiodir/download.tmp
        INST=0
    else
        echo "${CYN}$appname New Version Available!${NC}"
        mv -f $radiodir/download.tmp /opt/downloads/yaac.zip
        rm -rf $appdir/$appname
        INST=1
    fi    
else
    mv -f $radiodir/download.tmp /opt/downloads/yaac.zip
    INST=1
fi    
if [ $INST -eq 1 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    echo "${CYN}Unpacking $appname...${NC}"
    unzip yaac.zip >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c 'echo "java -jar /opt/build/radio-tools/yaac/YAAC.jar" > /usr/local/bin/yaac'
    sudo chmod ugo+rx /usr/local/bin/yaac
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=direwolf # APRS Reciever
check_update $radiodir/$appname https://github.com/wb2osz/direwolf.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    cd src
    if [ ! -d build ]; then
        mkdir build
    fi
    cmake ../ >> $logdir$appname.log 2>&1
    # Install Start
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "make install-conf >> $logdir$appname.log 2>&1"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=lysdr # SDR Reciever
check_update $radiodir/$appname https://github.com/gordonjcp/lysdr.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    ./autogen.sh >> $logdir$appname.log 2>&1
    ./configure  >> $logdir$appname.log 2>&1
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=multimon-ng # 
check_update $radiodir/$appname https://github.com/EliasOenal/multimon-ng.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir -p build
    cd build
    cmake ../ >> $logdir$appname.log 2>&1
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=gnss-sdr # 
check_update $radiodir/$appname https://github.com/gnss-sdr/gnss-sdr.git $appname
if [ $? = 21 ]; then
    echo "${CYN}Preparing $appname...${NC}"
    # Install Start
    mkdir build
    cd build
    cmake ../ >> $logdir$appname.log 2>&1
    echo "${CYN}Compiling $appname...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo "${CYN}Installing $appname...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}$appname Install Error! Check $logdir$appname.log${NC}"
    else    
        echo "${GRN}$appname Install Complete!${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi


