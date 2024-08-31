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

# menu1 starts here #
function menu1() {
    echo ""
	echo -ne "$(ColorYellow 'Syslog Management')"
    echo ""
sudo ./syslog-management.sh
    echo ""
}
# menu1 ends here #



# menu2 starts here #
function menu2() {
    echo ""
	echo -ne "$(ColorYellow 'Syslog Management')"
    echo ""
sudo ./syslog-management.sh
    echo ""
}
# menu2 ends here #



# menu3 starts here #
function menu3() {
	echo ""
	echo -ne "$(ColorYellow 'Syslog Management')"
    echo ""
sudo ./syslog-management.sh
    echo ""
}
# proxy-services endss here #




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
SYSLOG MANAGEMENT
$(ColorGreen '1)') Menu1
$(ColorGreen '2)') Menu2
$(ColorGreen '3)') Menu3
$(ColorGreen '0)') Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) menu1 ; menu ;;
	        2) menu2 ; menu ;;			
	        3) menu3 ; menu ;;
	        0) initial-menu ; menu ;;			
		*) echo -e $red"Wrong option."
        esac
}
# Call the menu function
menu
	read input
	done
:2	