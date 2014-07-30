## make sure that we are root

if [ `id -u` -ne 0 ]; then echo "this script must be run by root" && exit 1; fi

## keep an eye out for errors
RETURN_CODE=0

function check_errors {
  if [ $RETURN_CODE -ne 0 ]; then
    echo "error while ${@}"
    exit 1
  fi
}

## Change this to the node id that we are configuring
NODE_ID=00

echo "DDC-Node-${NODE_ID}" > /etc/hostname
RETURN_CODE=$?; check_errors "setting hostname"

if [ `grep "^auto eth0" /etc/network/interfaces | wc -l` -eq 0 ]; then

  printf "auto eth0\n\iface eth0 inet static\n  address 10.10.200.`expr 150 + $NODE_ID`\n  netmask 255.255.255.0\n  network 10.10.200.0\n  gateway 10.10.200.1\n" >> /etc/network/interfaces
  RETURN_CODE=$?; check_errors "configuring network (eth0)"

  shutdown -r now
fi

## create downloads directory
cd ~/
RETURN_CODE=$?; check_errors "changing to home directory"

mkdir -p downloads
RETURN_CODE=$?; check_errors "making download directory"

## get the package manager working as well as we can
apt-get -y update
RETURN_CODE=$?; check_errors "apt-get update"

apt-get -y install ntp
RETURN_CODE=$?; check_errors "installing ntp"

apt-get -y install autoconf
RETURN_CODE=$?; check_errors "installing autoconf"

apt-get -y install automake
RETURN_CODE=$?; check_errors "installing automake"

apt-get -y install libtool
RETURN_CODE=$?; check_errors "installing libtool"

## install nfc dependencies
cd ~/downloads
RETURN_CODE=$?; check_errors "changing to downloads directory"

apt-get install libusb-dev
RETURN_CODE=$?; check_errors "installing libusb-dev"

## install libusb-compat
wget http://sourceforge.net/projects/libusb/files/libusb-compat-0.1/libusb-compat-0.1.5/libusb-compat-0.1.5.tar.bz2
RETURN_CODE=$?; check_errors "wget libusb-compat from sourceforge.net"

tar xjf libusb-compat-0.1.5.tar.bz2
RETURN_CODE=$?; check_errors "untar libusb-compat"

cd libusb-compat-0.1.5
RETURN_CODE=$?; check_errors "changing to libusb-compat-0.1.5 directory"

./configure
RETURN_CODE=$?; check_errors "configure libusb-compat"

make && make install
RETURN_CODE=$?; check_errors "make install libusb-compat"

cd ~/downloads
RETURN_CODE=$?; check_errors "returning to downloads directory"

rm -rf libusb-compat-0.1.5
RETURN_CODE=$?; check_errors "removing libusb-compat-0.1.5 directory"

## install the nfc libs
apt-get -y install libusb-0.1-4
RETURN_CODE=$?; check_errors "installing libusb-0.1-4"

apt-get -y install libccid 
RETURN_CODE=$?; check_errors "installing libccid"

## install libnfc
git clone git://anonscm.debian.org/collab-maint/libnfc.git
RETURN_CODE=$?; check_errors "get clone libnfc"

cd libnfc
RETURN_CODE=$?; check_errors "changing to libnfc directory"

autoreconf -vis
RETURN_CODE=$?; check_errors "autoreconf libnfc"

./configure
RETURN_CODE=$?; check_errors "configure libnfc"

make && make install
RETURN_CODE=$?; check_errors "make install libnfc"

cp -v contrib/udev/42-pn53x.rules /lib/udev/rules.d/
RETURN_CODE=$?; check_errors "copying pn53x rules"

ldconfig
RETURN_CODE=$?; check_errors "updating libraries (ldconfig)"

cd ~/downloads
RETURN_CODE=$?; check_errors "returning to downloads directory"

## todo delete libnfc directory

## configuring libnfc
printf "device.name = \"elechouse_pn532_uart\"\ndevice.connstring = \"pn532_uart:/dev/ttyO1\"\n" > /usr/local/etc/nfc/libnfc.conf
RETURN_CODE=$?; check_errors "configuring libnfc"


## create a link to the cloud9 dir in the home dir cakked bone, for ease of access

ln -s /var/lib/cloud9/ bone
RETURN_CODE=$?; check_errors "setting hostname"
