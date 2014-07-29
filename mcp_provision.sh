
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

cd ~/
ln -s /var/lib/cloud9/ bone
mkdir
mkdir downloads
## get the config repo if we can and do some simple stuff first
HAS_CONFIG_REPO=git clone git@github.com:misterinterrupt/bone-configure.git

if $HAS_CONFIG_REPO ; then
	cd bone-configure
	cp configs/mcp/hostname /etc/hostname
	cp configs/mcp/interfaces /etc/network/interfaces
	ntpdate -b -s -u pool.ntp.org
else
	printf '%s\n' 'could not get config repo.\n' >&2
	exit 1;
fi

## get the package manager working as well as we can
apt-get -y update
apt-get -y install
apt-get -y couchdb
cd ~/bone/javascripts

HAS_MCP_REPO=git clone https://github.com/misterinterrupt/mixpanel-ddc-master

if $HAS_MCP_REPO ; then
	cd mixpanel-ddc-master
else
	printf '%s\n' 'could not get mcp repo.\n' >&2
	exit 1
fi

if [!npm install] ; then
	printf '%s\n' 'could not install npm dependencies.\n' >&2
	exit 1
fi

BOWER_INSTALLED=bower install
if [!BOWER_INSTALLED] ; then
		printf '%s\n' 'could not install npm dependencies.\n' >&2
		exit 1
fi

printf '%s\n' 'dependencies are all installation.\n' >&2