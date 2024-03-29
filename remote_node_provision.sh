
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

## create a link to the cloud9 dir in the home dir cakked bone, for ease of access
cd ~/
ln -s /var/lib/cloud9/ bone
mkdir downloads


echo "DDC_Node" > /etc/hostname
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces

## get the package manager working as well as we can
apt-get -y update
apt-get -y install
apt-get -y install autoconf automake libtool libusb-1.0-0-dev
apt-get -y install minicom


# get the overlays for UARTO1 at ttyO1 or something..
# cd ~/downloads
# wget http://s3.armhf.com/boards/bbb/dt/ttyO1_armhf.com-00A0.dtbo
# cp ttyO1_armhf.com-00A0.dtbo /lib/firmware


## install of nfc lib dependencies
## Install the Libusb Compatibility Library
## Download libusb-compat-0.1.5.tar.bz2 from libusb, uncompress it, and install it like so:
cd ~/downloads
apt-get install libusb-dev libpcsclite-dev
wget http://sourceforge.net/projects/libusb/files/libusb-compat-0.1/libusb-compat-0.1.5/libusb-compat-0.1.5.tar.bz2
tar xjf libusb-compat-0.1.5.tar.bz2
cd libusb-compat-0.1.5
./configure
make
make install

## install the nfc libs
cd ~/downloads
apt-get -y install libusb-0.1-4 libpcsclite1 libccid pcscd
git clone git://anonscm.debian.org/collab-maint/libnfc.git
cd libnfc
autoreconf -vis
./configure
make
make install
## copy the PN53x rules file from the libnfc distribution as follows:
cp -v contrib/udev/42-pn53x.rules /lib/udev/rules.d/

## update linker to be able to find libs
ldconfig

cd /var/lib/cloud9/
mkdir /usr/local/etc/nfc/
git clone git@github.com:misterinterrupt/bone-configure.git
cp -v bone-config/configs/remote_node/libnfc.conf /usr/local/etc/nfc/libnfc.conf


## Installing libfreefare
## Now that you have libnfc installed, download and install libfreefare:
cd ~/downloads
git clone https://code.google.com/p/libfreefare/
cd libfreefare
autoreconf -vis
./configure
make
make install

## update linker to be able to find libs
ldconfig

## update the time
ntpdate -b -s -u pool.ntp.org

## copy modprobe blacklist file for libnfc
cp bone-config/configs/remote_node/blacklist-libnfc.conf /etc/modprobe.d/blacklist-libnfc.conf

## get LEDScape on the box!
cd /root
git clone git@github.com:Yona-Appletree/LEDscape.git
cd LEDScape
make
cp /boot/am335x-boneblack.dtb{,.preledscape_bk}
cp am335x-boneblack.dtb /boot/
modprobe uio_pruss
systemctl enable ledscape.service



## clone our custom git repo and install stuff
## !!! depends on the ssh credentials, of course
cd ~/bone/javascripts
git clone git@github.com:misterinterrupt/mixpanel-ddc
cd mixpanel-ddc/nfc-node
npm install

## we need to reboot now



