#!/bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# install homebrew
echo -e "[-] ${GREEN}install homebrew...${RESET}"
if ! type "brew" > /dev/null; then
    echo -e "[!] ${YELLOW}homebrew is not installed, would you like to install that? [y/n] ${RESET} "
    read -r input
    
    case $input in
        [yY][eE][sS]|[yY])
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        ;;
        
        [nN][oO]|[nN])
            echo -e "[x] ${RED}Abort.${RESET}"
            exit 1
        ;;
        
        *)
            echo -e "[x] ${RED}Invalid input, abort.${RESET}"
            exit 1
        ;;
    esac
fi

# install dependencies
echo -e "[-] ${GREEN}install dependencies...${RESET}"
if ! type "iproxy" > /dev/null; then
    brew install -y libusbmuxd
fi
if ! type "sshpass" > /dev/null; then
    brew install -y https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
fi

# will begin
echo -e "[!] ${YELLOW}this script only supports iDevice up to iOS 13.2.3${RESET}"
echo -e "[!] ${YELLOW}connect your iDevice to your Mac, then press [Enter] to start...${RESET}"
read -p ""

# bind SSH ports
echo -e "[-] ${GREEN}bind SSH ports from 12222 to 444...${RESET}"
iproxy 12222 44 > /dev/null 2>&1
echo $! > .iproxy.pid
trap 'kill -9 $(cat .iproxy.pid); exit 1' INT

# execute payload
echo -e "[-] ${GREEN}execute payload...${RESET}"
sshpass -p alpine ssh -o StrictHostKeyChecking=no -p 12222 root@127.0.0.1 <<-'ENDSSH'
if [[ ! -d "/Applications/Setup.app.bypass" ]]; then
    mount -o rw,union,update /;
    mv /Applications/Setup.app /Applications/Setup.app.bypass;
    killall -9 Setup;
    uicache --all;
    killall -9 backboardd;
    exit 0;
fi
exit 1;
ENDSSH

# test payload
if [[ $? -ne 0 ]]; then
    echo -e "[x] ${RED}bypass failed${RESET}"
    exit 1
fi

# clean up
kill -9 $(cat .iproxy.pid) > /dev/null
rm -f .iproxy.pid > /dev/null
echo -e "[-] ${GREEN}bypass succeed${RESET}"
exit 0

