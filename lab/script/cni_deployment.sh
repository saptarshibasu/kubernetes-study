#!/bin/bash

# Setting up a webserver for testing
sudo apt upgrade -y
sudo apt install apache2 -y
sudo ufw allow 'Apache'
cd /var/www/html
echo "<html><h1>Hello AWS Study - Welcome To My Webpage</h1><body>`hostnamectl`</body></html>" > index.html

# Installing CNI plugin
sudo apt upgrade -y
curl https://raw.githubusercontent.com/Azure/azure-container-networking/v1.1.7/scripts/install-cni-plugin.sh > install-cni-plugin.sh
chmod +x install-cni-plugin.sh
sudo ./install-cni-plugin.sh v1.1.7 v0.8.7