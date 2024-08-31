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

# proxy-setup-configurations starts here #
function proxy-setup-configurations() {
    echo ""
sudo ./proxy-setup-configurations.sh
    echo ""
    echo ""	
}
# proxy-setup-configurations ends here #



# proxy-remove-configurations starts here #
function proxy-remove-configurations() {
    echo ""
sudo ./proxy-remove-configurations.sh
    echo ""
    echo ""	
}
# proxy-remove-configurations ends here #



# proxy-maintenance starts here #
function proxy-maintenance() {
	echo ""
    echo ""
sudo ./proxy-maintenance.sh
    echo ""
}
# proxy-services endss here #



# proxy-logs starts here #
function proxy-logs() {
echo ""
echo -ne "$(ColorYellow 'Last 10 logs are listed below.')"
    echo ""	
docker logs --tail 10 zabbix-proxy
    echo ""
    read -p " "  -t 360
sudo ./proxy-setup-configurations.sh	
}
# proxy-logs ends here #







# initial-menu starts here #
function initial-menu() {
    echo ""
sudo ./menu.sh
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
PROXY MANAGEMENT
$(ColorGreen '1)') Setup Configurations
$(ColorGreen '2)') Remove Configurations
$(ColorGreen '3)') Maintenance
$(ColorGreen '4)') Logs
$(ColorGreen '0)') Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) proxy-setup-configurations ; menu ;;
	        2) proxy-remove-configurations ; menu ;;			
	        3) proxy-maintenance ; menu ;;
	        4) proxy-logs ; menu ;;
	        0) initial-menu ; menu ;;			
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}
# Call the menu function
menu
	read input
	done
:2	