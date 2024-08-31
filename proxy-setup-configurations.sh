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


# server-connections starts here #
function server-connections() {
    echo ""
function safe_mkdir {
    if [ ! -d "$1" ]; then
      mkdir "$1"
    fi
}


HOSTNAME=`hostname`

read -p "$(ColorYellow 'Use hostname '${HOSTNAME}' for proxy hostname (Y/n)? ')" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  read -p "$(ColorYellow 'Enter proxy hostname: ')" HOSTNAME
fi

read -p "$(ColorYellow 'Active proxy (Y/n)? ')" -n 1 -r
echo
if [[ ${REPLY} =~ ^[nN]$ ]]; then
  # Passive proxy
  echo "$(ColorYellow 'Configuring passive proxy')"
  PASSIVE_PROXY="1"
else
  read -p "$(ColorYellow 'Enter Zabbix server hostname: ')" SERVER_HOST
  read -p "$(ColorYellow 'Enter Zabbix server port: ')" SERVER_PORT
fi

safe_mkdir zabbix
safe_mkdir zabbix/enc
safe_mkdir zabbix/externalscripts
safe_mkdir zabbix/snmptraps

echo "alpine-7.0-latest" >zabbix/container.version

echo "ZBX_HOSTNAME=${HOSTNAME}" >>proxy.env
if [ -z "$PASSIVE_PROXY" ]; then
  echo "ZBX_SERVER_HOST=${SERVER_HOST}" >>proxy.env
  echo "ZBX_SERVER_PORT=${SERVER_PORT}" >>proxy.env
else
  echo "ZBX_PROXYMODE=1" >>proxy.env
  echo "ZBX_SERVER_HOST=0.0.0.0/0" >>proxy.env
fi
echo "ZBX_CONFIGFREQUENCY=300" >>proxy.env
echo "ZBX_CACHESIZE=1000M" >>proxy.env
echo "ZBX_STARTHTTPPOLLERS=20" >>proxy.env
echo "ZBX_TIMEOUT=30" >>proxy.env
echo "ZBX_STARTPOLLERSUNREACHABLE=20" >>proxy.env
echo "ZBX_STARTPOLLERS=50" >>proxy.env
echo "ZBX_STARTTRAPPERS=50" >>proxy.env
echo "ZBX_HISTORYINDEXCACHESIZE=20M" >>proxy.env
echo "ZBX_HISTORYCACHESIZE=40M" >>proxy.env
echo "ZBX_STARTDISCOVERERS=3" >> proxy.env
echo "ZBX_STARTDBSYNCERS=6" >> proxy.env
echo "ZBX_ENABLE_SNMP_TRAPS=true" >> proxy.env
	echo ""
	read -p "$(ColorYellow 'Connection config is completing.')" -t 3
    echo ""
sudo ./proxy-setup-configurations.sh	
}
# server-connections ends here #




# server-encryption starts here #
function server-encryption() {
    echo ""


function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}


PSK_FILE=zabbix_proxy.psk

# Obtain PSK identity
  read -p "$(ColorYellow 'Enter PSK identity : ')" input
PSK_IDENTITY=${input:-$PSK_IDENTITY}




# Obtain PSK key
  read -p "$(ColorYellow 'Enter pre-generated PSK key - leave empty to generate one now:  ')" PSK_KEY
if [ "${PSK_KEY}" == "" ]; then
  PSK_KEY=`openssl rand -hex 32`

  echo "$(ColorYellow 'Generated PSK:  ')" ${PSK_KEY}
  echo
fi

# Check for PSK file
if [ -e "zabbix/enc/${PSK_FILE}" ]; then
  read -p "$(ColorYellow 'Old PSK key file exists - remove [y/N]? ')" -n 1 -r
  echo  
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${PSK_FILE}"
  read -p "$(ColorYellow 'Copy generated PSK code because this menu will be redirected to the setup configuration menu in 10 seconds.')"  -t 10	
  else
    read -p "$(ColorYellow 'Encryption setup terminated, you are going to be redirected to the setup configuration menu.')"  -t 20
sudo ./proxy-setup-configurations.sh	
   exit 0
  fi
fi

# Create PSK file
echo "${PSK_KEY}" >"zabbix/enc/${PSK_FILE}"

# Given the right rights
chown 1997:1995  "zabbix/enc/${PSK_FILE}"
chmod 0600  "zabbix/enc/${PSK_FILE}"

# Setup environment options
opt_replace ZBX_TLSCONNECT psk proxy.env
opt_replace ZBX_TLSACCEPT psk proxy.env
opt_replace ZBX_TLSPSKIDENTITY "${PSK_IDENTITY}" proxy.env
opt_replace ZBX_TLSPSKFILE "${PSK_FILE}" proxy.env
 echo ""
sudo ./proxy-setup-configurations.sh 
}
# server-encryption ends here #



# container-installation starts here #
function container-installation() {
	echo ""	
	echo -ne "$(ColorYellow 'Container installations will be completed soon. Later you can use the Log menu to check it out what is happening.')"
	echo ""	
export CONTAINER_VERSION=`cat zabbix/container.version`
export CONTAINER_IMAGE=`cat zabbix/container.image`
if [ -z "$CONTAINER_IMAGE" ]; then
  CONTAINER_IMAGE="zabbix/zabbix-proxy-sqlite3"
fi

if [ "$1" == "-help" ]; then
  echo "Usage: $(basename $0) [ <container-name> [ <container-version> ] ]"
  echo
  echo "Default for container name is 'zabbix-proxy' and version is '${CONTAINER_VERSION}'"
  echo
  exit 0
fi


DIR=`realpath $(dirname $0)`
NAME=${1:-zabbix-proxy}
CONTAINER_VERSION=${2:-${CONTAINER_VERSION}}
PSK_FILE=zabbix/enc/zabbix_proxy.psk
START_CMD="docker-entrypoint.sh"

if [ "$(docker ps -a -f name=${NAME} | awk '{print $NF}' | grep -e ^${NAME}$)" ]; then
  echo "Container with name '${NAME}' already exists. Stop and remove old container before creating new one."
  exit 1
elif [ "$(docker ps -a -f name=zabbix-snmptraps | awk '{print $NF}' | grep -e ^zabbix-snmptraps$)" ]; then
  echo "Container with name 'zabbix-snmptraps' already exists. Stop and remove old container before creating new one."
  exit 1
fi

echo "Creating container [${NAME}] using image [${CONTAINER_IMAGE}:${CONTAINER_VERSION}]."

touch zabbix/snmptraps/snmptraps.log
chmod g+w zabbix/snmptraps/snmptraps.log

docker-compose up -d

    echo ""	
    echo ""
sudo ./proxy-setup-configurations.sh 	
}
# setup-ends ends here #



# show-settings starts here #
function show-settings() {
echo ""
echo -ne "$(ColorYellow 'Proxy Settings are shown below.')"
    echo ""	
    echo ""	
cat  proxy.env
    read -p " "  -t 10
sudo ./proxy-setup-configurations.sh	
}
# show-settings ends here #

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
SETUP CONFIGURATIONS
$(ColorGreen '1)') Server Connections
$(ColorGreen '2)') Server Encryptions
$(ColorGreen '3)') Container Installations
$(ColorGreen '4)') Show Settings
$(ColorGreen '0)') Previous Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) server-connections ; menu ;;
	        2) server-encryption ; menu ;;
	        3) container-installation ; menu ;;			
	        4) show-settings ; menu ;;											
	        0) initial-menu ; menu ;;	
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}
# Call the menu function
menu
	read input
	done
:2	