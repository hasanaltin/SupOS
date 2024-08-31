#!/bin/bash

trap '' 2
while true
do
clear



# remove-configuration starts here #
function remove-configuration() {
    echo ""
	read -p "$(ColorYellow 'Keep waiting, configuration is being removed.')" -t 3
    echo ""
    echo ""
sed --in-place '/ZBX_ENABLE_SNMP_TRAPS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_HOSTNAME/d' proxy.env  > /dev/null
sed --in-place '/ZBX_SERVER_HOST/d' proxy.env  > /dev/null
sed --in-place '/ZBX_SERVER_PORT/d' proxy.env  > /dev/null

sed --in-place '/ZBX_CONFIGFREQUENCY/d' proxy.env  > /dev/null
sed --in-place '/ZBX_CACHESIZE/d' proxy.env  > /dev/null
sed --in-place '/ZBX_STARTHTTPPOLLERS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TIMEOUT/d' proxy.env  > /dev/null
sed --in-place '/STARTPOLLERSUNREACHABLE/d' proxy.env  > /dev/null
sed --in-place '/ZBX_STARTPOLLERS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_STARTTRAPPERS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_HISTORYINDEXCACHESIZE/d' proxy.env  > /dev/null
sed --in-place '/ZBX_HISTORYCACHESIZE/d' proxy.env  > /dev/null
sed --in-place '/ZBX_STARTDISCOVERERS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_STARTDBSYNCERS/d' proxy.env  > /dev/null


sudo ./proxy-remove-configurations.sh

}
# remove-configuration ends here #




# remove-encryption starts here #
function remove-encryption () {
    echo ""
	read -p "$(ColorYellow 'Keep waiting, encryptions is being removed.')" -t 3
    echo ""	
sed --in-place '/ZBX_TLSACCEPT/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSCONNECT/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSPSKIDENTITY/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSPSKFILE/d' proxy.env  > /dev/null
    echo ""	
sudo ./proxy-remove-configurations.sh	
}
# remove-encryption ends here #




# remove-containers starts here #
function remove-containers() {
	echo ""	
	read -p "$(ColorYellow 'Keep waiting, containers are being removed.')" -t 3
    echo ""
docker-compose down  | grep "zabbix" > /dev/null
    echo ""
	sudo ./proxy-remove-configurations.sh
}
# remove-containers ends here #



# initial-menu starts here #
function initial-menu() {
    echo ""
sudo ./proxy-management.sh
    echo ""
    echo ""	
}
# initial-menu ends here #

##
# Color  Variables
##
green='\e[32m'
blue='\e[34m'
yellow='\e[1;33m'
clear='\e[0m'
##
# Color Functions
##
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}
ColorYellow(){
	echo -ne $yellow$1$clear
}
menu(){
echo -ne "
REMOVE CONFIGURATIONS
$(ColorGreen '1)') Remove Connections
$(ColorGreen '2)') Remove Encryptions
$(ColorGreen '3)') Remove Containers
$(ColorGreen '0)') Previous Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in			
	        1) remove-configuration ; menu ;;
	        2) remove-encryption  ; menu ;;
	        3) remove-containers ; menu ;;														
	        0) initial-menu ; menu ;;	
		*) echo -e $red"Wrong option."
        esac
}
# Call the menu function
menu
	read input
	done
:2	