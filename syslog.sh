#!/bin/bash
##
# BASH menu script that checks:
#   - Memory usage
#   - CPU load
#   - Number of TCP connections 
#   - Kernel version
##




# menu1 starts here #
function menu1() {
    echo ""
	echo -ne "$(ColorYellow 'Menu1 is selected.')"
    echo ""
}
# menu1 ends here #



# menu2 starts here #
function menu2() {
    echo ""
	echo -ne "$(ColorYellow 'Menu2 is selected.')"
    echo ""
}
# menu2 ends here #



# menu3 starts here #
function menu3() {
    echo ""
	echo -ne "$(ColorYellow 'Menu3 is selected.')"
    echo ""
}
# menu3 ends here #





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
Proxy Management
$(ColorGreen '1)') Menu 1
$(ColorGreen '2)') Menu 2
$(ColorGreen '3)') Menu 3
$(ColorGreen '0)') Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) menu1 ; menu ;;
	        2) menu2 ; menu ;;
	        3) menu3 ; menu ;;														
		0) exit 0 ;;
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}
# Call the menu function
menu
