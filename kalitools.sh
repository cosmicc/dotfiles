#!/bin/env sh

YEL='\033[1;33m'
GRN='\033[1;32m'
CYN='\033[1;36m'
MGT='\033[1;35m'
NC='\033[0m'

wifidir=/opt/wifitools
logdir=/opt/logs
logfile=/opt/logs/wifitools.log

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

echo "${YEL}Starting Kali Application Installer!${NC}"
echo "Starting Kali Tools Installer - `date`" > $logfile

if [ ! -d $wifidir ]; then
    echo "${MGT}Kalitools Directory doesn't exist, creating.${NC}"
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

echo -n "${YEL}Install Kali Repository (y/n)? ${NC}" 
read answer
if [ $answer = "y" ]; then
    echo "${CYN}Installing Kali Repository...${NC}"
    sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED444FF07D8D0BF6
    sudo echo '# Kali linux repositories | Added by Katoolin\ndeb http://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list
    echo "${CYN}Updating packages to Kali rolling versions...${NC}"
    sudo apt -qq update
    sudo apt -qq upgrade -y

    echo "${CYN}Installing Tools Prerequisites...${NC}" 
    sudo apt -qq install python3-scapy subversion python3-pyqt5 pyqt5-dev-tools qttools5-dev-tools -y

    echo -n "${YEL}Install Kali Tools (y/n)? ${NC}" 
    read answerb
    if [ $answerb = "y" ]; then
        echo "${CYN}Installing All Kali Tools...${NC}" 
        sudo apt -qq install acccheck ace-voip amap automater braa casefile cdpsnarf cisco-torch cookie-cadger copy-router-config dmitry dnmap dnsenum dnsmap dnsrecon dnstracer dnswalk dotdotpwn enum4linux enumiax exploitdb fierce firewalk fragroute fragrouter ghost-phisher golismero goofile lbd maltego-teeth masscan metagoofil miranda nmap p0f parsero recon-ng set smtp-user-enum snmpcheck sslcaudit sslsplit sslstrip sslyze thc-ipv6 theharvester tlssled twofi urlcrazy wireshark wol-e xplico ismtp intrace hping3 bbqsql bed cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch copy-router-config doona dotdotpwn greenbone-security-assistant hexorbase jsql lynis nmap ohrwurm openvas-cli openvas-manager openvas-scanner oscanner powerfuzzer sfuzz sidguesser siparmyknife sqlmap sqlninja sqlsus thc-ipv6 tnscmd10g unix-privesc-check yersinia aircrack-ng asleap bluelog blueranger bluesnarfer bully cowpatty crackle eapmd5pass fern-wifi-cracker ghost-phisher giskismet gqrx kalibrate-rtl killerbee kismet mdk3 mfcuk mfoc mfterm multimon-ng pixiewps reaver redfang spooftooph wifi-honey wifitap apache-users arachni bbqsql blindelephant burpsuite cutycapt davtest deblaze dirb dirbuster fimap funkload grabber jboss-autopwn joomscan jsql maltego-teeth padbuster paros parsero plecost powerfuzzer proxystrike recon-ng skipfish sqlmap sqlninja sqlsus ua-tester uniscan vega w3af webscarab websploit wfuzz wpscan xsser zaproxy burpsuite dnschef fiked hamster-sidejack hexinject iaxflood inviteflood ismtp mitmproxy ohrwurm protos-sip rebind responder rtpbreak rtpinsertsound rtpmixsound sctpscan siparmyknife sipp sipvicious sniffjoke sslsplit sslstrip thc-ipv6 voiphopper webscarab wifi-honey wireshark xspy yersinia zaproxy cryptcat cymothoa dbd dns2tcp http-tunnel httptunnel intersect nishang polenum powersploit pwnat ridenum sbd u3-pwn webshells weevely casefile cutycapt dos2unix dradis keepnote magictree metagoofil nipper-ng pipal armitage backdoor-factory cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch crackle jboss-autopwn linux-exploit-suggester maltego-teeth set shellnoob sqlmap thc-ipv6 yersinia beef-xss binwalk bulk-extractor chntpw cuckoo dc3dd ddrescue dumpzilla extundelete foremost galleta guymager iphone-backup-analyzer p0f pdf-parser pdfid pdgmail peepdf volatility xplico dhcpig funkload iaxflood inviteflood ipv6-toolkit mdk3 reaver rtpflood slowhttptest t50 termineter thc-ipv6 thc-ssl-dos acccheck burpsuite cewl chntpw cisco-auditing-tool cmospwd creddump crunch findmyhash gpp-decrypt hash-identifier hexorbase john johnny keimpx maltego-teeth maskprocessor multiforcer ncrack oclgausscrack pack patator polenum rainbowcrack rcracki-mt rsmangler statsprocessor thc-pptp-bruter truecrack webscarab wordlists zaproxy apktool dex2jar python-distorm3 edb-debugger jad javasnoop jd ollydbg smali valgrind yara android-sdk apktool arduino dex2jar sakis3g smali hping nmap nikto
    fi
fi    
