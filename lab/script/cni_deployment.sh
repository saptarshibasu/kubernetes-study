#!/bin/bash

sudo apt upgrade -y

echo "Installing CNI plugin"
sudo wget https://raw.githubusercontent.com/Azure/azure-container-networking/v1.1.7/scripts/install-cni-plugin.sh
sudo chmod +x install-cni-plugin.sh
sudo ./install-cni-plugin.sh v1.1.7 v0.8.7

echo "Setting up a webserver for testing"
sudo apt install apache2 -y
sudo ufw allow 'Apache'
cd /var/www/html
echo "<html><h1>Hello AWS Study - Welcome To My Webpage</h1><body>`hostnamectl`</body></html>" | sudo tee index.html
