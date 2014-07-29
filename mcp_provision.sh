
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
cd ~/
ln -s /var/lib/cloud9/ bone
mkdir
mkdir downloads

echo "mcp" > /etc/hostname
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces
ntpdate -b -s -u pool.ntp.org