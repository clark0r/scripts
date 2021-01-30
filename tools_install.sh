#!/bin/bash
apt update -y
apt upgrade -y

# standard tooling
apt install -y git screen net-tools

# nmap & vulners
apt install -y nmap
mkdir -p /opt/vulners
git clone https://github.com/vulnersCom/nmap-vulners.git /opt/vulners/
cp /opt/vulners/*.nse /usr/share/nmap/scripts/
cp /opt/vulners/http-vulners-paths.txt /usr/share/nmap/nselib/data/
cp /opt/vulners/http-vulners-regex.json /usr/share/nmap/nselib/data/
nmap --script-updatedb

# gobuster
apt install -y gobuster

# scoutsuite
apt install -y python3-pip
pip3 install scoutsuite

# metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall

# az-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# exploitdb
mkdir -p /opt/exploitdb
git clone https://github.com/offensive-security/exploitdb.git /opt/exploitdb/
ln -s /opt/exploitdb/searchsploit /usr/bin/

# sslscan
apt install -y build-essential git zlib1g-dev
add-apt-repository -s "deb http://azure.archive.ubuntu.com/ubuntu/ focal main restricted"
apt-get -y build-dep openssl
mkdir -p /opt/sslscan
git clone https://github.com/rbsec/sslscan.git /opt/sslscan
cd /opt/sslscan
make static
ln -s /opt/sslscan/sslscan /usr/bin/

# wordlists
mkdir -p /opt/wordlists
wget https://github.com/danTaler/WordLists/raw/master/Subdomain.txt -O /opt/wordlists/subdomains

# wpscan
apt install -y ruby ruby-dev
gem install wpscan

# trufflehog
pip3 install trufflehog