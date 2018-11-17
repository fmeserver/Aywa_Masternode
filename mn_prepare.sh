#!/bin/bash

COIN_NAME='Aywa'


BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'



function add_user(){

        echo -e  'Enter new user name:'
        read -e NEWUSERNAME
        adduser $NEWUSERNAME
        #add it to sudoers
        usermod -aG sudo $NEWUSERNAME
        #allow ssh
        #does AllowUsers section already exists at sshd_config?
        grep -q "AllowUsers $NEWUSERNAME" /etc/ssh/sshd_config
        if [ $? -ne 0 ]; then
                echo "Allow ssh for $NEWUSERNAME"
                echo "AllowUsers $NEWUSERNAME" >> /etc/ssh/sshd_config
        else
                echo 'no changes needed'
        fi
        grep -q "DenyUsers root" /etc/ssh/sshd_config
        if [ $? -ne 0 ]; then
                echo "Deny ssh for root"
                echo "DenyUsers root" >> /etc/ssh/sshd_config
        else
                echo 'no changes needed'
        fi

}


function add_swap() {
        # size of swapfile in megabytes
        swapsize=4096

        # does the swap file already exist?
        grep -q "swapfile" /etc/fstab

        # if not then create it
        if [ $? -ne 0 ]; then
                echo 'swapfile not found. Adding swapfile.'
                fallocate -l ${swapsize}M /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap defaults 0 0' >> /etc/fstab
        else
                echo 'swapfile found. No changes made.'
        fi

        # output results to terminal
        cat /proc/swaps
        cat /proc/meminfo | grep Swap
}


function install_dependencies() {

echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Masternode${NC}"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--for$
apt install -y software-properties-common
echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update
apt-get install libzmq3-dev fail2ban -y 
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make sof$
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev $
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bs$
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by$
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev $
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake $
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip$
 exit 1
fi
#clear 
}


##### Main #####

#clear
add_user
add_swap
install_dependencies
