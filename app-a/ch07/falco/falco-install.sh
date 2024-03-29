#!/usr/bin/env bash

curl -s https://falco.org/repo/falcosecurity-packages.asc | sudo apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
sudo apt-get update -y
sudo apt-get -y install linux-headers-$(uname -r)
sudo apt-get install -y falco=0.33.1