#!/bin/env sh

YEL='\033[1;33m'
GRN='\033[1;32m'
CYN='\033[1;36m'
MGT='\033[1;35m'
NC='\033[0m'

wifidir=/opt/build/wifitools
logdir=/opt/logs/wifitools/
logfile=/opt/logs/wifitools.log
failedlog=wififailed.log
FAILED=0

escape_slashes () {
    sed 's/\//\\\//g'
}

change_line () {
    local OLD_LINE_PATTERN=$1; shift
    local NEW_LINE=$1; shift
    local FILE=$1
    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    sed -i .bak '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
    mv "${FILE}.bak" /tmp/
}

git_check () {
    echo -n "${CYN}Checking ${MGT}$3${CYN}...${NC}"
    if [ -d $1 ]; then
        cd $1
        LOCAL=`git rev-parse HEAD` > /dev/null 2>&1
        REMOTE=`git ls-remote | grep HEAD` > /dev/null 2>&1
        LOCAL2="${LOCAL##*$'\n'}" > /dev/null 2>&1
        REMOTE2=`echo $REMOTE | cut -d' ' -f 1` > /dev/null 2>&1
        if [ $LOCAL2 = $REMOTE2 ]; then
            echo "${CYN}No Updates Available.${NC}"
            return 58
        else
            echo -n "${YEL}New Version! Downloading...${NC}"
            git pull >> $logfile 2>&1
            return 21
        fi
    else
        echo -n "${YEL}Does Not Exist! Downloading...${NC}"
        mkdir -p $1
        git clone $2 $1 >> $logfile 2>&1
        cd $1
        git config pull.rebase false
        return 21
    fi
}

echo "${YEL}Starting Wifi/Bluetooth Application Installer!${NC}"
echo "Starting Wifi Tools Installer - `date`" > $logfile

if [ ! -d $wifidir ]; then
    echo "${MGT}Wifitools Directory doesn't exist, creating.${NC}"
    mkdir -p $wifidir
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
rm $logdir$failedlog
touch $logdir$failedlog

echo "${CYN}Installing Wifi Tools Prerequisites...${NC}" 
sudo sh -c "apt -qq install net-tools libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre3-dev libhwloc-dev libcmocka-dev hostapd wpasupplicant tcpdump screen iw usbutils tshark libpcap-dev ettercap-graphical lighttpd crunch ieee-data dsniff ccze mdk4 libglib2.0-dev libnetfilter-queue-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libsdl1.2-dev libsmpeg-dev subversion libportmidi-dev ffmpeg libswscale-dev libavformat-dev libavcodec-dev -y >> $logfile 2>&1"

sudo sh -c "apt -qq install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libfreetype6-dev libportmidi-dev build-dep libsdl2 libsdl2-image libsdl2-mixer libsdl2-ttf libfreetype6 python3 libportmidi0 libxml2-dev libxslt-dev python-tk -y >> $logfile 2>&1"

echo "${CYN}Installing MAC and Hostname Changer...${NC}"
sudo sh -c "apt -qq install macchanger -y"
sudo cp templates/hostnamechanger /usr/local/bin
sudo cp templates/hostnamechanger.py /usr/local/bin
sudo ln -s /usr/local/bin/hostnamechanger /etc/network/if-pre-up.d/hostnamechanger
sudo chmod ugo+x /usr/local/bin/hostnamechanger
sudo chmod ugo+x /etc/network/if-pre-up.d/hostnamechanger
sudo /usr/local/bin/hostnamechanger

appname=aircrack-ng
git_check $wifidir/$appname https://github.com/aircrack-ng/aircrack-ng.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Preparing...${NC}"
    # Install Start
    autoreconf -i >> $logdir$appname.log 2>&1
    ./configure --with-experimental --with-gcrypt --with-ext-scripts >> $logdir$appname.log 2>&1
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=pixiewps
git_check $wifidir/$appname https://github.com/wiire-a/pixiewps.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Preparing...${NC}"
    # Install Start
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))

    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=reaver
git_check $wifidir/$appname https://github.com/t6x/reaver-wps-fork-t6x $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Preparing...${NC}"
    # Install Start
    cd src
    ./configure >> $logdir$appname.log 2>&1
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=bully
git_check $wifidir/$appname https://github.com/aanarchyy/bully $appname
if [ $? = 21 ]; then
    cd src
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=cowpatty
git_check $wifidir/$appname https://github.com/joswr1ght/cowpatty.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=hashcat
git_check $wifidir/$appname https://github.com/hashcat/hashcat.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=hcxdumptool
git_check $wifidir/$appname https://github.com/ZerBea/hcxdumptool.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=hcxtools
git_check $wifidir/$appname https://github.com/ZerBea/hcxtools.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=sslstrip
git_check $wifidir/$appname https://github.com/moxie0/sslstrip.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Prerequisites...${NC}"
    sudo sh -c "python2 -m pip install twisted >> $logfile 2>&1"
    sudo sh -c "python2 -m pip install pyOpenSSL >> $logfile 2>&1"
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
    else    
        echo -n "${CYN}Installing...${NC}"
        sudo sh -c "python2 setup.py install >> $logdir$appname.log 2>&1"
        # Install End
        if [ $? -ne 0 ]; then
            echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
            echo $appname\n >> $logdir$failedlog
            ((FAILED=FAILED+1))
        else    
            echo "${GRN}Complete.${NC}"
            sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
        fi
    fi    
fi

appname=bettercap
git_check $wifidir/$appname https://github.com/bettercap/bettercap.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Preparing...${NC}"
    # Install Start
    echo -n "${CYN}Compiling...${NC}"
    make clean >> $logdir$appname.log 2>&1
    make build -j4 >> $logdir$appname.log 2>&1
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi


#appname=mdk4
#git_check $wifidir/$appname https://github.com/aircrack-ng/mdk4 $appname
#if [ $? = 21 ]; then
#    echo -n "${CYN}Installing...${NC}"
#    make clean >> $logdir$appname.log 2>&1
#    make -j4 >> $logdir$appname.log 2>&1
#    echo -n "${CYN}Installing...${NC}"
#    sudo sh -c "make install >> $logdir$appname.log 2>&1"
    # Install End
#    if [ $? -ne 0 ]; then
#        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
#       echo $appname\n >> $logdir$failedlog
#       ((FAILED=FAILED+1))
#    else    
#        echo "${GRN}Complete.${NC}"
#        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
#    fi    
#fi


appname=wifite2
git_check $wifidir/$appname https://github.com/derv82/wifite2.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "python3 setup.py install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=lazyaircrack
git_check $wifidir/$appname https://github.com/3xploitGuy/lazyaircrack.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    chmod +x lazyaircrack.sh >> $logdir$appname.log 2>&1
    chmod +x airplay.sh >> $logdir$appname.log 2>&1
    sudo cp lazyaircrack.sh /usr/local/bin/lazyaircrack -f
    sudo cp airplay.sh /usr/local/bin/airplay -f
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=airgeddon
git_check $wifidir/$appname https://github.com/v1s1t0r1sh3r3/airgeddon.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    chmod +x airgeddon.sh >> $logdir$appname.log 2>&1
    cp airgeddon.sh /usr/local/bin/airgeddon -f
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi



appname=reconcobra
git_check $wifidir/$appname https://github.com/HackerUniverse/Reconcobra.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "chmod u+x *.sh >> $logdir$appname.log 2>&1"
    sudo bash installer.sh
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
        sudo sh -c "echo 'cd /opt/build/wifitools/reconcobra\nsudo perl ReconCobra.pl' > /usr/local/bin/reconcobra"
        sudo sh -c "chmod +x /usr/local/bin/reconcobra"
    fi    
fi

appname=routersploit
git_check $wifidir/$appname https://github.com/threat9/routersploit.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "python3 -m pip install -r requirements.txt >> $logdir$appname.log 2>&1"
    sudo sh -c "python3 -m pip install bluepy >> $logdir$appname.log 2>&1"
    sudo sh -c "python3 rsf.py"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
        sudo sh -c "echo 'cd /opt/build/wifitools/routersploit\nsudo python3 rsf.py' > /usr/local/bin/routersploit"
        sudo sh -c "chmod +x /usr/local/bin/routersploit"
    fi    
fi

appname=wifi-hacker
git_check $wifidir/$appname https://github.com/esc0rtd3w/wifi-hacker.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sed -i '/pathAircrack="\/usr\/bin\/aircrack-ng"/c\    pathAircrack="\/usr\/local\/bin\/aircrack-ng"' $wifidir/wifi-hacker/wifi-hacker.sh
    sed -i '/pathAireplay="\/usr\/sbin\/aireplay-ng"/c\    pathAireplay="\/usr\/local\/sbin\/aireplay-ng"' $wifidir/wifi-hacker/wifi-hacker.sh
    sed -i '/pathAirodump="\/usr\/sbin\/airodump-ng"/c\    pathAirodump="\/usr\/local\/sbin\/airodump-ng"' $wifidir/wifi-hacker/wifi-hacker.sh
    sed -i '/pathBesside="\/usr\/sbin\/besside-ng"/c\    pathBesside="\/usr\/local\/sbin\/besside-ng"' $wifidir/wifi-hacker/wifi-hacker.sh
    sed -i '/pathPacketforge="\/usr\/sbin\/packetforge-ng"/c\    pathPacketforge="\/usr\/local\/sbin\/packetforge-ng"' $wifidir/wifi-hacker/wifi-hacker.sh
    sed -i '/pathReaver="\/usr\/bin\/reaver"/c\    pathReaver="\/usr\/local\/bin\/reaver"' $wifidir/wifi-hacker/wifi-hacker.sh
    sudo sh -c 'cp /opt/build/wifitools/wifi-hacker/wifi-hacker.sh /usr/local/bin/wifi-hacker'
    sudo sh -c "chmod +x /usr/local/bin/wifi-hacker"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
    fi    
fi

appname=kickthemout
git_check $wifidir/$appname https://github.com/R3DDY97/KICKthemOUT3.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "python3 -m pip install -r requirements.txt >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
        sudo sh -c "echo 'cd /opt/build/wifitools/kickthemout\nsudo python3 kick3.py' > /usr/local/bin/kickthemout"
        sudo sh -c "chmod +x /usr/local/bin/kickthemout"
    fi    
fi

appname=peniot
git_check $wifidir/$appname https://github.com/yakuza8/peniot.git $appname
if [ $? = 21 ]; then
    echo -n "${CYN}Installing...${NC}"
    sudo sh -c "python2 setup.py install >> $logdir$appname.log 2>&1"
    # Install End
    if [ $? -ne 0 ]; then
        echo "${MGT}Install Error! Check $logdir$appname.log${NC}"
        echo $appname\n >> $logdir$failedlog
        ((FAILED=FAILED+1))
    else    
        echo "${GRN}Complete.${NC}"
        sudo sh -c "ldconfig >> $logdir$appname.log 2>&1"
        sudo sh -c "echo 'cd /opt/build/wifitools/peniot/src\nsudo python2 peniot.py' > /usr/local/bin/peniot"
        sudo sh -c "chmod +x /usr/local/bin/peniot"
    fi    
fi

if [ $FAILED -gt 0 ]; then
   echo "${MGT}$FAILED installs failed${NC}"
   cat $logdir$failedlog
else
    echo "${GRN}All Completed with 0 Errors${NC}"
fi

#echo "${CYN}Installing bing-ip2hosts...${NC}" 
#wget http://www.morningstarsecurity.com/downloads/bing-ip2hosts-0.4.tar.gz
#tar -xzvf bing-ip2hosts-0.4.tar.gz
#sudo cp bing-ip2hosts-0.4/bing-ip2hosts /usr/local/bin/
#sudo rm -r bing-ip2hosts-0.4
#sudo rm bing-ip2hosts-0.4.tar.gz
#https://github.com/threat9/routersploit.gitpython3 -m pip install -r requirements.txt
