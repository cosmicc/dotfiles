YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

echo "${CYN}Installing Kali Repository...${NC}"
apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED444FF07D8D0BF6
sudo echo '# Kali linux repositories | Added by Katoolin\ndeb http://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list

echo "${CYN}Updating packages to Kali rolling versions...${NC}"
sudo apt -qq update
sudo apt -qq upgrade -y

echo "${CYN}Installing Tools Prerequisites...${NC}" 
sudo apt -qq install python3-scapy subversion macchanger python3-pyqt5 pyqt5-dev-tools qttools5-dev-tools -y

echo "${CYN}Installing All Kali Tools...${NC}" 
sudo apt -qq install acccheck ace-voip amap automater braa casefile cdpsnarf cisco-torch cookie-cadger copy-router-config dmitry dnmap dnsenum dnsmap dnsrecon dnstracer dnswalk dotdotpwn enum4linux enumiax exploitdb fierce firewalk fragroute fragrouter ghost-phisher golismero goofile lbd maltego-teeth masscan metagoofil miranda nmap p0f parsero recon-ng set smtp-user-enum snmpcheck sslcaudit sslsplit sslstrip sslyze thc-ipv6 theharvester tlssled twofi urlcrazy wireshark wol-e xplico ismtp intrace hping3 bbqsql bed cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch copy-router-config doona dotdotpwn greenbone-security-assistant hexorbase jsql lynis nmap ohrwurm openvas-cli openvas-manager openvas-scanner oscanner powerfuzzer sfuzz sidguesser siparmyknife sqlmap sqlninja sqlsus thc-ipv6 tnscmd10g unix-privesc-check yersinia aircrack-ng asleap bluelog blueranger bluesnarfer bully cowpatty crackle eapmd5pass fern-wifi-cracker ghost-phisher giskismet gqrx kalibrate-rtl killerbee kismet mdk3 mfcuk mfoc mfterm multimon-ng pixiewps reaver redfang spooftooph wifi-honey wifitap apache-users arachni bbqsql blindelephant burpsuite cutycapt davtest deblaze dirb dirbuster fimap funkload grabber jboss-autopwn joomscan jsql maltego-teeth padbuster paros parsero plecost powerfuzzer proxystrike recon-ng skipfish sqlmap sqlninja sqlsus ua-tester uniscan vega w3af webscarab websploit wfuzz wpscan xsser zaproxy burpsuite dnschef fiked hamster-sidejack hexinject iaxflood inviteflood ismtp mitmproxy ohrwurm protos-sip rebind responder rtpbreak rtpinsertsound rtpmixsound sctpscan siparmyknife sipp sipvicious sniffjoke sslsplit sslstrip thc-ipv6 voiphopper webscarab wifi-honey wireshark xspy yersinia zaproxy cryptcat cymothoa dbd dns2tcp http-tunnel httptunnel intersect nishang polenum powersploit pwnat ridenum sbd u3-pwn webshells weevely casefile cutycapt dos2unix dradis keepnote magictree metagoofil nipper-ng pipal armitage backdoor-factory cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch crackle jboss-autopwn linux-exploit-suggester maltego-teeth set shellnoob sqlmap thc-ipv6 yersinia beef-xss binwalk bulk-extractor chntpw cuckoo dc3dd ddrescue dumpzilla extundelete foremost galleta guymager iphone-backup-analyzer p0f pdf-parser pdfid pdgmail peepdf volatility xplico dhcpig funkload iaxflood inviteflood ipv6-toolkit mdk3 reaver rtpflood slowhttptest t50 termineter thc-ipv6 thc-ssl-dos acccheck burpsuite cewl chntpw cisco-auditing-tool cmospwd creddump crunch findmyhash gpp-decrypt hash-identifier hexorbase john johnny keimpx maltego-teeth maskprocessor multiforcer ncrack oclgausscrack pack patator polenum rainbowcrack rcracki-mt rsmangler statsprocessor thc-pptp-bruter truecrack webscarab wordlists zaproxy apktool dex2jar python-distorm3 edb-debugger jad javasnoop jd ollydbg smali valgrind yara android-sdk apktool arduino dex2jar sakis3g smali hping nmap nikto

echo "${CYN}Installing Wifite2...${NC}" 
sudo apt -qq install wifite -y

echo "${CYN}Installing bing-ip2hosts...${NC}" 
wget http://www.morningstarsecurity.com/downloads/bing-ip2hosts-0.4.tar.gz
tar -xzvf bing-ip2hosts-0.4.tar.gz
cp bing-ip2hosts-0.4/bing-ip2hosts /usr/local/bin/
rm -r bing-ip2hosts-0.4
rm bing-ip2hosts-0.4.tar.gz

if [ ! -d "/opt/build/wifi" ]; then
    mkdir /opt/guild/wifi
fi

echo "${CYN}Installing Lazy Air Crack...${NC}" 
git clone https://github.com/3xploitGuy/lazyaircrack.git /opt/build/wifi-tools/lazyaircrack 1> /dev/null

echo "${CYN}Installing Lazy Airgeddon...${NC}" 
git clone --depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git /opt/build/wifi-tools/airgeddon 1> /dev/null

echo "${CYN}Installing Recon Cobra...${NC}" 
git clone https://github.com/haroonawanofficial/ReconCobra.git /opt/build/sec-tools/reconcobra 1> /dev/null


