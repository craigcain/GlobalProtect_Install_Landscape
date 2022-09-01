#!/bin/bash

##################################################
# Script to deploy global protect to ubuntu user
# Created by James Spencer
# 17 August 2022
################################################

# Manually set the download URL
gp_download=https://globalprotect-client.s3.eu-west-2.amazonaws.com/GlobalProtect_UI_deb-6.0.1.1-6.deb

# Setting variables
package_name=$(echo $gp_download | awk -F '/' '{print $4}')
gp_version=$(echo $package_name | awk -F '-' '{print $2}' | cut -c 1-5)

# Set up folders and files
mkdir -p /usr/share/form3/network/Global-Protect-Client/$gp_version
cd /usr/share/form3/network/Global-Protect-Client/$gp_version
echo $gp_version > gp-version.txt 

# Create install script
echo "Creating installer script"
echo "#!/bin/bash

dpkg -i /usr/share/form3/network/Global-Protect-Client/$gp_version/$package_name 

rm -f /etc/xdg/autostart/global-protect-install.desktop" > /usr/share/form3/network/Global-Protect-Client/$gp_version/gp_installer.sh

chmod +x /usr/share/form3/network/Global-Protect-Client/$gp_version/gp_installer.sh

# Download Global protect

if [[ ! -x /usr/share/form3/network/Global-Protect-Client/$gp_version/$package_name ]]; then
    echo "downloading package"
    wget $gp_download
    chmod +x /usr/share/form3/network/Global-Protect-Client/$gp_version/$package_name
else
    echo "Package already downloaded"
fi    

# Check global protect version
current_gp=$(globalprotect show --version | awk 'NR==1{print $2}' | cut -c 1-5)

if [[ $current_gp != $gp_version ]]; then
    echo "Global protect version $current_gp is currently installing."
    echo "Will install version $gp_version"
else 
    echo "Global protect is up to date. Aborting script"
    exit 0
fi

# Set up login script

if [[ ! -f /etc/xdg/autostart/global-protect-install.desktop ]]; then
echo "Creating .desktop file"
echo "[Desktop Entry]
Type=Application
Terminal=false
Exec=/usr/share/form3/network/Global\ Protect\ Client/$gp_version/gp_installer.sh
Name=global-protect-install-script" > /etc/xdg/autostart/global-protect-install.desktop

echo "Making .desktop file executable"
chmod +x /etc/xdg/autostart/global-protect-install.desktop
fi

exit 