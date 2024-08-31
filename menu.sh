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



# proxy starts here #
function proxy() {
    echo ""
sudo ./proxy-management.sh
    echo ""
    echo ""	
}
# proxy ends here #



# syslog starts here #
function syslog() {
    echo ""
sudo ./syslog-management.sh
    echo ""
    echo ""	
}
# syslog ends here #



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
SUPOS MANAGEMENT MENU
$(ColorGreen '1)') Proxy Management
$(ColorGreen '2)') Syslog Management
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in			
	        1) proxy ; menu ;;
	        2) syslog ; menu ;;						
		0) exit 0 ;;
		*) echo -e $red"Wrong option."
        esac
}
# Call the menu function
menu
	read input
	done
:2	