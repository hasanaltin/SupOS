#!/bin/bash
##
# BASH menu script that checks:
#   - Memory usage
#   - CPU load
#   - Number of TCP connections 
#   - Kernel version
##



# setup-config starts here #
function setup-config() {
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
echo "ZBX_JAVAGATEWAY_ENABLE=true" >>proxy.env
echo "ZBX_JAVAGATEWAYPORT=10052" >>proxy.env
echo "ZBX_STARTJAVAPOLLERS=20" >>proxy.env
echo "ZBX_STARTPOLLERSUNREACHABLE=20" >>proxy.env
echo "ZBX_STARTPOLLERS=50" >>proxy.env
echo "ZBX_STARTTRAPPERS=50" >>proxy.env
echo "ZBX_HISTORYINDEXCACHESIZE=20M" >>proxy.env
echo "ZBX_HISTORYCACHESIZE=40M" >>proxy.env
echo "ZBX_STARTDISCOVERERS=3" >> proxy.env
echo "ZBX_STARTDBSYNCERS=6" >> proxy.env
echo "ZBX_ENABLE_SNMP_TRAPS=true" >> proxy.env
	echo ""
	echo -ne "$(ColorYellow 'Setup config is completed.')"
    echo ""	
}
# setup-config ends here #



# remove-config starts here #
function remove-config() {
    echo ""
	echo -ne "$(ColorYellow 'Configuration is removed.')"
    echo ""
sed --in-place '/ZBX_ENABLE_SNMP_TRAPS/d' proxy.env  > /dev/null
sed --in-place '/ZBX_HOSTNAME/d' proxy.env  > /dev/null
sed --in-place '/ZBX_SERVER_HOST/d' proxy.env  > /dev/null
sed --in-place '/ZBX_SERVER_PORT/d' proxy.env  > /dev/null
}
# remove-config ends here #


# setup-psk starts here #
function setup-psk() {
    echo ""


function opt_replace {
  grep -q "^$1" "$3" && sed -i "s|^$1.*|$1=$2|" "$3" || echo "$1=$2" >>"$3"
}

PSK_IDENTITY=PSK_001
PSK_FILE=zabbix_proxy.psk

# Obtain PSK identity
read -p "Enter PSK identity [${PSK_IDENTITY}]: " input
PSK_IDENTITY=${input:-$PSK_IDENTITY}

# Obtain PSK key
read -p "Enter pre-generated PSK key - leave empty to generate one now: " PSK_KEY
if [ "${PSK_KEY}" == "" ]; then
  PSK_KEY=`openssl rand -hex 32`

  echo "Generated PSK: ${PSK_KEY}"
  echo
fi

# Check for PSK file
if [ -e "zabbix/enc/${PSK_FILE}" ]; then
  read -p "Old PSK key file exists - remove [y/N]?" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[yY]$ ]]; then
    rm "zabbix/enc/${PSK_FILE}"
  else
    echo "PSK setup terminated."
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
}
# setup-psk ends here #



# remove-psk starts here #
function remove-psk() {
    echo ""
	echo -ne "$(ColorYellow 'PSK configuration is removed.')"
    echo ""	
sed --in-place '/ZBX_TLSACCEPT/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSCONNECT/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSPSKIDENTITY/d' proxy.env  > /dev/null
sed --in-place '/ZBX_TLSPSKFILE/d' proxy.env  > /dev/null
    echo ""	
}
# remove-psk ends here #


# setup-proxy starts here #
function setup-proxy() {
	echo ""	
set -e

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
	echo -ne "$(ColorYellow 'Setup Proxy is completed and containers started.')"	
    echo ""
}
# setup-ends ends here #



# remove-proxy starts here #
function remove-proxy() {
	echo ""	
set -e

docker-compose down  > /dev/null

    echo ""
	echo -ne "$(ColorYellow 'Proxy is removed.')"	
    echo ""
}
# remove-proxy ends here #



# proxy-stop starts here #
function proxy-stop() {
	echo ""
	echo -ne "$(ColorYellow 'Following services are stopped.')"	
    echo ""
docker stop zabbix-proxy zabbix-snmptraps
    echo ""
}
# proxy-stop endss here #


# proxy-start starts here #
function proxy-start() {
	echo ""
	echo -ne "$(ColorYellow 'Following services are started.')"
    echo ""
docker start zabbix-proxy zabbix-snmptraps
    echo ""
}
# proxy-start ends here #



# proxy-logs starts here #
function proxy-logs() {
echo ""
echo -ne "$(ColorYellow 'Last 10 logs are listed below.')"
    echo ""	
docker logs --tail 10 zabbix-proxy
    echo ""
}
# proxy-logs ends here #


# show-settings starts here #
function show-config() {
echo ""
echo -ne "$(ColorYellow 'Proxy Settings are shown below.')"
    echo ""	
    echo ""	
cat  proxy.env
    echo ""
}
# show-settings ends here #


# proxy-factory-default starts here #
function proxy-factory-default() {
	echo ""	
set -e

docker-compose down  > /dev/null
rm -r zabbix* proxy.env  > /dev/null

    echo ""
	echo -ne "$(ColorYellow 'Proxy factory-default is completed.')"
    echo ""
}
# proxy-factory-default ends here #




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
Proxy Management Menu
$(ColorGreen '1)') Setup Config
$(ColorGreen '2)') Setup PSK
$(ColorGreen '3)') Setup Proxy
$(ColorGreen '4)') Remove Config
$(ColorGreen '5)') Remove PSK
$(ColorGreen '6)') Remove Proxy
$(ColorGreen '7)') Stop Proxy
$(ColorGreen '8)') Start Proxy
$(ColorGreen '9)') Proxy Logs
$(ColorGreen '10)') Show Settings
$(ColorGreen '11)') Factory Default
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) setup-config ; menu ;;
	        2) setup-psk ; menu ;;
	        3) setup-proxy ; menu ;;			
	        4) remove-config ; menu ;;
	        5) remove-psk ; menu ;;
	        6) remove-proxy ; menu ;;			
	        7) proxy-stop ; menu ;;
	        8) proxy-start ; menu ;;
	        9) proxy-logs ; menu ;;
	        10) show-settings ; menu ;;					
	        11) proxy-factory-default ; menu ;;							
		0) exit 0 ;;
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}
# Call the menu function
menu
