
source helper.sh

echo "${CYN}Disabling Unused Filesystems...${NC}"
spinner
cp templates/login.defs /etc/login.defs

echo "${CYN}Disabling Unused Filesystems...${NC}"
spinner
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf

echo "${CYN}Disabling Unused Net Protocols...${NC}"
spinner
echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf

echo "${CYN}Securing SSH...${NC}"
spinner
sed s/USERNAME/$username/g templates/sshd_config > /etc/ssh/sshd_config; echo "OK"
chattr -i /home/$username/.ssh/authorized_keys
sudo service ssh restart

echo "${CYN}Securing IPTables...${NC}"
spinner
sudo sh templates/iptables.sh
sudo cp templates/iptables.sh /etc/init.d/
sudo chmod +x /etc/init.d/iptables.sh
sudo ln -s /etc/init.d/iptables.sh /etc/rc2.d/S99iptables.sh

echo "${CYN}Installing Fail2Ban...${NC}"
spinner
sudo apt -qq install fail2ban

