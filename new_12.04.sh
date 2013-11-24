#!/bin/sh
#author hellok
#for update new 12.04

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Enable password-less sudo for the current user.
sudo sh -c "echo '$USER ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"
sudo chmod 0400 /etc/sudoers.d/$USER


sudo tee /etc/apache2/sites-available/001-crbuilds.conf > /dev/null <<EOF
deb http://mirror.bit.edu.cn/ubuntu/ raring main restricted universe multiverse
deb http://mirror.bit.edu.cn/ubuntu/ raring-security main restricted universe multiverse
deb http://mirror.bit.edu.cn/ubuntu/ raring-updates main restricted universe multiverse
deb http://mirror.bit.edu.cn/ubuntu/ raring-backports main restricted universe multiverse
deb http://mirror.bit.edu.cn/ubuntu/ raring-proposed main restricted universe multiverse
deb-src http://mirror.bit.edu.cn/ubuntu/ raring main restricted universe multiverse
deb-src http://mirror.bit.edu.cn/ubuntu/ raring-security main restricted universe multiverse
deb-src http://mirror.bit.edu.cn/ubuntu/ raring-updates main restricted universe multiverse
deb-src http://mirror.bit.edu.cn/ubuntu/ raring-backports main restricted universe multiverse
deb-src http://mirror.bit.edu.cn/ubuntu/ raring-proposed main restricted universe multiverse
EOF


# When upgrading, keep modified configuration files, overwrite unmodified ones.
sudo tee /etc/apt/apt.conf.d/90-no-prompt > /dev/null <<'EOF'
Dpkg::Options {
"--force-confdef";
"--force-confold";
}
EOF

# Enable the multiverse reposistory, for ttf-mscorefonts-installer.
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list

# Update all system packages.
sudo apt-get update -qq
sudo apt-get -y dist-upgrade

# debconf-get-selections is useful for figuring out debconf defaults.
sudo apt-get install -y debconf-utils

# Quiet all package installation prompts.
sudo debconf-set-selections <<'EOF'
debconf debconf/frontend select Noninteractive
debconf debconf/priority select critical
EOF

# Web server for the builds.
sudo apt-get install -y apache2
sudo apt-get install -y pkg-config
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libdbus-1-dev
sudo apt-get install -y libdrm-dev
sudo apt-get install -y libgconf2-dev
sudo apt-get install -y libgnome-keyring-dev
sudo apt-get install -y libpci-dev
sudo apt-get install -y libudev-dev


sudo mkdir -p /etc/apache2/sites-available
sudo tee /etc/apache2/sites-available/001-crbuilds.conf > /dev/null <<EOF
<VirtualHost *:80>
ServerAdmin webmaster@localhost

DocumentRoot /home/$USER/crbuild.www
<Directory />
Options FollowSymLinks
AllowOverride None
</Directory>
<Directory /home/$USER/crbuild.www>
Options Indexes FollowSymLinks MultiViews
AllowOverride None
Order allow,deny
allow from all
</Directory>

ErrorLog /var/log/apache2/error.log
LogLevel warn
CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
sudo ln -s -f /etc/apache2/sites-available/001-crbuilds.conf \
/etc/apache2/sites-enabled/001-crbuilds.conf
sudo rm -f /etc/apache2/sites-enabled/*default
sudo /etc/init.d/apache2 restart

# Git.
sudo apt-get install -y git