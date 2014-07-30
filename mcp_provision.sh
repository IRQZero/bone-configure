
#!/bin/
export DEBIAN_FRONTEND=noninteractive

## will we need to add and use a new user to run our ddc-mcp-serv.d ?
#useradd -mrU -s /bin/bash ddc-mcp-serv

cd ~/
ln -s /var/lib/cloud9/ bone
mkdir
mkdir downloads
## get the config repo if we can and do some simple stuff first

if [ls bone-configure]; then
	printf '%s\n' 'can already has config repo.\n' >&2
else
	if git clone git@github.com:misterinterrupt/bone-configure.git; then
		cd bone-configure
		cp configs/mcp/hostname /etc/hostname
		cp configs/mcp/interfaces /etc/network/interfaces
		ntpdate -b -s -u pool.ntp.org
	else
		printf '%s\n' 'could not get config repo.\n' >&2
		exit 1;
	fi
fi

## get the package manager working as well as we can
apt-get -y update
apt-get -y install
apt-get -y couchdb
cd ~/bone/javascripts

if [ls mixpanel-ddc-master]; then
	printf '%s\n' 'can already has mcp repo.\n' >&2	
else 
	if git clone https://github.com/misterinterrupt/mixpanel-ddc-master; then
		cd mixpanel-ddc-master
	else
		printf '%s\n' 'could not get mcp repo.\n' >&2
		exit 1
	fi
fi

if [npm install] ; then
	:
else
	printf '%s\n' 'could not install npm dependencies.\n' >&2
	exit 1
fi

if bower install ; then
	:
else	
	printf '%s\n' 'could not install npm dependencies.\n' >&2
	exit 1
fi

printf '%s\n' 'dependencies are all installation.\n' >&2

