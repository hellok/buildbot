#!/bin/sh
#author hellok
sudo tee /etc/network/interfaces > /dev/null <<'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 166.111.132.173
gateway 166.111.132.1
netmask 255.255.255.0
network 166.111.132.0
broadcast 166.111.132.255
EOF


sudo /etc/init.d/networking restart
sudo tee /etc/resolv.conf > /dev/null <<'EOF'
nameserver 8.8.8.8
EOF