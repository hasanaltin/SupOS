#!/bin/bash
##
# BASH menu script that checks:
#   - Memory usage
#   - CPU load
#   - Number of TCP connections 
#   - Kernel version
##
trap '' 2
while true
do
clear

# proxy-stop starts here #
function proxy-stop() {
	echo ""
	echo -ne "$(ColorYellow 'Following services are being stopped.')"
    echo ""
docker stop zabbix-proxy zabbix-snmptraps
    echo ""
	read -p "$(ColorYellow '')"	-t 5	
sudo ./proxy-maintenance.sh	
}
# proxy-stop endss here #


# proxy-start starts here #
function proxy-start() {
	echo ""
	echo -ne "$(ColorYellow 'Following services are being started.')"
    echo ""
docker start zabbix-proxy zabbix-snmptraps
    echo ""
	read -p "$(ColorYellow '')"	-t 5	
sudo ./proxy-maintenance.sh	
}
# proxy-start ends here #



# proxy-services-status starts here #
function proxy-services-status() {
	echo ""
	echo -ne "$(ColorYellow 'Docker services status for Proxy Management')"
    echo ""
sudo systemctl status docker
    echo ""
	read -p "$(ColorYellow '')"	-t 5	
sudo ./proxy-maintenance.sh	
}
# proxy-services-status ends here #





# proxy-status starts here #
function proxy-status() {
	echo ""
	echo -ne "$(ColorYellow 'Proxy Management containers status')"
    echo ""
sudo docker ps
    echo ""
	read -p "$(ColorYellow '')"	-t 20	
sudo ./proxy-maintenance.sh	
}
# proxy-statust ends here #




# proxy-update here #
function proxy-update() {
	echo ""
	echo -ne "$(ColorYellow 'Proxy Update status')"
    echo ""
git status
    echo ""
	read -p "$(ColorYellow '')"	-t 20	
sudo ./proxy-maintenance.sh	
}
# proxy-update ends here #


# proxy-factory-default starts here #
function proxy-factory-default() {
	echo ""	

docker-compose down  > /dev/null
rm -r zabbix* proxy.env  > /dev/null

    echo ""
	read -p "$(ColorYellow 'Proxy factory-default is completed.')" -t 5
    echo ""
sudo ./proxy-management.sh	
}
# proxy-factory-default ends here #


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
PROXY MAINTENANCE
$(ColorGreen '1)') Stop Services
$(ColorGreen '2)') Start Services
$(ColorGreen '3)') Services Status
$(ColorGreen '4)') Proxy Status
$(ColorGreen '5)') Proxy Update 
$(ColorGreen '6)') Factory Default Settings
$(ColorGreen '0)') Previous Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in			
	        1) proxy-stop ; menu ;;
	        2) proxy-start  ; menu ;;
	        3) proxy-services-status ; menu ;;
	        4) proxy-status ; menu ;;	
	        5) proxy-update ; menu ;;
	        6) proxy-factory-default ; menu ;;				
	        0) initial-menu ; menu ;;	
		*) echo -e $red"Wrong option."
        esac
}
# Call the menu function
menu
	read input
	done
:2	