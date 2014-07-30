## keep running if we have an error so we can catch it
#trap '' ERR

## make sure that we are root

if [ `id -u` -ne 0 ]; then echo "this script must be run by root" && exit 1; fi

## keep an eye out for errors
## it would probably be easier to trap the errors
## but i'm more confident in exactly how this works
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

cd ~/
RETURN_CODE=$?; check_errors "changing to home directory"

apt-get -y update
RETURN_CODE=$?; check_errors "apt-get update"

## check if we've already installed this node
if [ -f ~/INSTALLED ]; then
  echo "It appears we have arleady installed this node. Proceeding to finalize install."
else
  ## create downloads directory
  mkdir -p downloads
  RETURN_CODE=$?; check_errors "making download directory"
  
  ## install packages
  
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
  
  apt-get install libusb-1.0-0-dev
  RETURN_CODE=$?; check_errors "installing libusb-1.0-0-dev"
  
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
  
  ## create modprobe blacklist file for libnfc
  printf "\"blacklist pn533\"\n\"blacklist nfc\"\n" > /etc/modprobe.d/blacklist-libnfc.conf
  RETURN_CODE=$?; check_errors "configuring modprobe blacklist for libnfc"
  
  ## install libfreefare
  git clone https://code.google.com/p/libfreefare/
  RETURN_CODE=$?; check_errors "git clone libfreefare"
  
  cd libfreefare
  RETURN_CODE=$?; check_errors "changing directory to libfreefare"
  
  autoreconf -vis
  RETURN_CODE=$?; check_errors "autoreconf libfreefare"
  
  ./configure
  RETURN_CODE=$?; check_errors "configure libfreefare"
  
  make && make install
  RETURN_CODE=$?; check_errors "make install libfreefare"
  
  cd ~/downloads
  RETURN_CODE=$?; check_errors "returning to downloads directory"
  
  ## todo delete libfreefare directory
  
  ## install LEDscape in root home directory
  cd ~/
  RETURN_CODE=$?; check_errors "changing to root home directory"
  
  git clone git@github.com:Yona-Appletree/LEDscape.git
  RETURN_CODE=$?; check_errors "git clone LEDscape"
  
  cd LEDScape
  RETURN_CODE=$?; check_errors "changing to LEDscape directory"
  
  make
  RETURN_CODE=$?; check_errors "make LEDscape"
  
  cp -v am335x-boneblack.dtb /boot/uboot/dtbs/
  RETURN_CODE=$?; check_errors "copy am335x-boneblack.dtb to dtbs folder"
  
  cd ~/
  RETURN_CODE=$?; check_errors "returning to root home directory"
  
  ## we're done with install
  
  echo date > ~/INSTALLED
  
  ## we need to reboot before we use LEDscape
  shutdown -r now

fi

if [ -f ~/READY ]; then

else
  
  ## finalize installation
  cd ~/
  RETURN_CODE=$?; check_errors "changing to root home directory"
  
  ## enable uio_pruss
  
  ## enable ledscape.service -- change launch to -1 NOP -c 113 -s 24
  
  ## setup ssh
  mkdir -p .ssh
  chmod 700 .ssh
  cd .ssh
  printf "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAuFc0U2K3Ro9x8yIhFLZwn36qPTaOE+Le+eDiRiwnBBKdixJj\niDvBiTISYIowOGIymNHPyH0BewCU7XByzvJzhzNGPvGeHT3c+BK9Wyl3cC+G6l9X\ni4Fy78bAn3bO2T1yezGUne9qbyVWDyzlJDjEV122jFgGyR2khT561W+XbLFE9fN\nCcTquOsIrt6Iym27jn3uovyRe2mAazpxXLQQTErBdFHE8pE4GU5CpHzJjlZAw6w2\n3flnoMdxD2VAwFJyei4WbwMtwE4hQo+siLAKJt7rQPhaTWweM6W/mQJZMf+rXFsO\nta/P+WeI5hZiOeqn+/17E62wNMHQZ2/IJcn/QwIDAQABAoIBAGWwrYvmZAZHsWuX\ngzpC3mQN4um7w6rSt4CO/yQIzUkg38nNThzkIgKGHb8l3C3udcz5yS7nTr7E9mL5\nakwhUXve3Dxy2290Jgavh8fXWy0G+t0l1Ux/D6GYOcB+MO2IF1LaDBmINpeBEb3I\nVqR5PNnifmMlY8f1WHeDnM6m0UosGImW58c0MYwKA6M+tOOmQCug2Yy18XUciwNb\ntGFbV3A0pqQbaToCtayu1eLBGJ8BVrthyjWybxayfZZCO853Pa2X6LePBdemhwNi\nov12Qp01ws6zXnHPAJhWi4qeR3HqB02CdT6pBGe7lrsScKWS1Vnr+aU1oddKoMc5\nad/egaECgYEA7Z9OURPCv2fOZNb7UcjLlbiRTdl96EjAJn/6cF9MYeKiHCCWdHdK\ntvVT6hs2EiEWZGERdv9zsifrePkItgMLmZS8KYzjxN5s1+Gs01I+nnCgtD/XtTz8\n2BMiXmn4EgOTCzKBulZsaeTe9c+WxfBlJlo98hsvJillMT/WWy84pdMCgYEAxpj5\nCwSaRz4jSpejmRqxLpwhAU3xEyaYcN6FNV/yR4zNHTetJJVVgRhjxzVWhphole5Y\nO7oXzlGG9Z/7eZO9OgcaoNux6cCIbBjo+l2DqwF55o+PmKDw3isOS73EMmA+NUHu\n5JyRoR3NdmXjvsHqqMNlFc+QZa8UI9GOeHmSKtECgYEA17RZf7gUfXRaI6gUFDXW\nuV8GaEkaxpXj+A8M5J1d1S3KQwZCDg+MP3GMb2OsPeDTVuPW2tMhz4P1ead3hOJW\n0V/3PzCqQrg2zfIK1Po/5cwP1hBuXBO04uDbviEsFA4ymWOL5/80AxzEWRfMonqL\nF7mrqe+LaXUCayasC7JeFgkCgYB4dTrBgxYs1jTDvrxdVkJYGh0u1F7AFe3qsB2u\nJTcoTO/wo9+iS+3j8q46m1CTLQhqwHnGKHbeDrdEbrgyovjopHxzSy5bsQtOPcG6\nclQ1uhx9S2B23E+dAhKWwFCrmZLB7O8AvTLbvd7szJpaDvbNTE8Y7qAP/STDIQ1A\nZ8TPsQKBgQDp2hfkaNBu8n3rZnEO3Mwt0DCf5AKZ1EmLPjxS+j21Z15qiJag2r/2\nO2DeXwyP5F9ZDcnu7pzFiRTwJiXBb1sXapHVTxhbjN3rfaZ9nDuk763GiRMBwZBQ\n9iLRk+RaPAnAV2NqpQcyYR4DRt9De5o74+st0BHJspttvDHN2b8zxA==\n-----END RSA PRIVATE KEY-----\n" > irq_rsa
  chmod 600 irq_rsa
  printf "sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4VzRTYrdGj3HzIiEUtnCffqo9No4T4t754OJGLCcEEp2LEmOIO8GJMhJgijA4YjKY0c/IfQF7AJTtcHLO8nOHM0Y+8Z4dPdz4Er1bKXdwL4bqX1eLgXLvxsCfds7rZPXJ7MZSd72pvJVYPLOUkOMRXXbaMWAbJHaSFPnrVb5dssUT180JxOq46wiu3ojKbbuOfe6i/JF7aYBrOnFctBBMSsF0UcTykTgZTkKkfMmOVkDDrDbd+Wegx3EPZUDAUnJ6LhZvAy3ATiFCj6yIsAom3utA+FpNbB4zpb+ZAlkx/6tcWw61r8/5Z4jmFmI56qf7/XsTrbA0wdBnb8glyf9D\n" > irq_rsa.pub
  printf "Host github.com\n  Hostname github.com\n  IdentityFile /root/.ssh/irq_rsa\n  User git" > config

  cd /srv
  RETURN_CODE=$?; check_errors "changing to /srv directory"

  ## clone git repo
  
  echo date > ~/READY

fi

## pull git repo
