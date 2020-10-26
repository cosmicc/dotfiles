
YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

echo "${CYN}Setting Restrictive UMASK...${NC}"
sudo cp templates/login.defs /etc/login.defs

echo "${CYN}Disabling Unused Filesystems...${NC}"
sudo sh -c 'echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf'

echo "${CYN}Disabling Unused Net Protocols...${NC}"
sudo sh -c 'echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf'
sudo sh -c 'echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf'

echo "${CYN}Securing SSH...${NC}"
sudo chmod go+w /etc/ssh
sudo chmod go+w /etc/ssh/sshd_config
sed s/USERNAME/$USER/g templates/sshd_config > /etc/ssh/sshd_config
sudo chown root.root /etc/ssh/sshd_config
sudo chmod go-w /etc/ssh
sudo chmod go-w /etc/ssh/sshd_config
chattr -i /home/$USER/.ssh/authorized_keys
sudo service ssh restart

echo "${CYN}Securing IPTables...${NC}"
sudo sh templates/iptables.sh
sudo cp templates/iptables.sh /etc/init.d/
sudo chmod +x /etc/init.d/iptables.sh
sudo ln -s /etc/init.d/iptables.sh /etc/rc2.d/S99iptables.sh

echo "${CYN}Installing Fail2Ban...${NC}"
sudo apt -qq install fail2ban -y
# sed s/MAILTO/$inbox/g templates/fail2ban > /etc/fail2ban/jail.local
sudo cp /etc/fail2ban/jail.local /etc/fail2ban/jail.conf
sudo /etc/init.d/fail2ban restart

echo "${CYN}Securing Kernel...${NC}"
sudo sh -c 'echo "* hard core 0" >> /etc/security/limits.conf'
sudo cp templates/sysctl.conf /etc/sysctl.conf
sudo cp templates/ufw /etc/default/ufw
sudo sysctl -e -p

echo "${CYN}Installing Rootkit Hunter...${NC}"
sudo apt -qq install rkhunter -y
sudo rkhunter --propupd

echo "${CYN}Installing Portsentry...${NC}"
sudo apt -qq install portsentry -y
sudo mv /etc/portsentry/portsentry.conf /etc/portsentry/portsentry.conf-original
sudo cp templates/portsentry /etc/portsentry/portsentry.conf
sudo sh -c 'sed s/tcp/atcp/g /etc/default/portsentry > salida.tmp'
sudo mv salida.tmp /etc/default/portsentry
sudo /etc/init.d/portsentry restart

echo "${CYN}Applying Additional Hardening...${NC}"
sudo echo tty1 > /etc/securetty
sudo chmod 0600 /etc/securetty
sudo chmod 700 /root
sudo chmod 600 /boot/grub/grub.cfg
sudo apt -qq purge at -y
sudo apt -qq install -y libpam-cracklib
sudo touch /etc/cron.allow
sudo chmod 600 /etc/cron.allow
sudo sh -c "awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny"

echo "${CYN}Installing Unhide...${NC}"
sudo apt -qq install unhide -y

echo "${CYN}Installing Tiger...${NC}"
sudo apt -qq install tiger -y

echo "${CYN}Installing PSAD...${NC}"
sudo apt -qq install psad -y
sudo cp templates/psad.conf /etc/psad/psad.conf
sudo psad --sig-update
sudo service psad restart

echo "${CYN}Installing Process Accounting...${NC}"
sudo apt -qq install acct -y
sudo touch /var/log/wtmp

echo "${CYN}Installing Auditd...${NC}"
sudo apt -qq install auditd -y
sudo cp templates/audit.rules /etc/audit/rules.d/audit.rules
sudo find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \
"-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \
-k privileged" } ' >> /etc/audit/rules.d/audit.rules
sudo echo " " >> /etc/audit/rules.d/audit.rules
sudo echo "#End of Audit Rules" >> /etc/audit/rules.d/audit.rules
sudo echo "-e 2" >>/etc/audit/rules.d/audit.rules
sudo systemctl enable auditd.service
sudo service auditd restart

echo "${CYN}Installing Sysstat...${NC}"
sudo apt -qq install sysstat -y
sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
sudo service sysstat start

echo "${CYN}Installing Arpwatch...${NC}"
sudo apt -qq install arpwatch -y
sudo systemctl enable arpwatch.service
sudo service arpwatch start

echo "${CYN}Hardening Critical File Permissions...${NC}"
sudo chmod -R g-wx,o-rwx /var/log/*
sudo chown root:root /etc/ssh/sshd_config
sudo chmod og-rwx /etc/ssh/sshd_config
sudo chown root:root /etc/passwd
sudo chmod 644 /etc/passwd
sudo chown root:shadow /etc/shadow
sudo chmod o-rwx,g-wx /etc/shadow
sudo chown root:root /etc/group
sudo chmod 644 /etc/group
sudo chown root:shadow /etc/gshadow
sudo chmod o-rwx,g-rw /etc/gshadow
sudo chown root:root /etc/passwd-
sudo chmod 600 /etc/passwd-
sudo chown root:root /etc/shadow-
sudo chmod 600 /etc/shadow-
sudo chown root:root /etc/group-
sudo chmod 600 /etc/group-
sudo chown root:root /etc/gshadow-
sudo chmod 600 /etc/gshadow-
echo -e "Setting Sticky bit on all world-writable directories"
sleep 2
sudo df --local -P | sudo awk {'if (NR!=1) print $6'} | sudo xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | sudo xargs chmod a+t
