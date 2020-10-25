YEL='\033[1;33m'
CYN='\033[1;36m' 
NC='\033[0m'

spinner ()
{
bar=" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
barlength=${#bar}
i=0
while ((i < 100)); do
    n=$((i*barlength / 100))
    printf "\e[00;34m\r[%-${barlength}s]\e[00m" "${bar:0:n}"
    ((i += RANDOM%5+2))
    sleep 0.02
 done
 }
