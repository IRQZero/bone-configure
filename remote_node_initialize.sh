#!/bin/bash
## leaving it up to you to make sure you dont run this outside of this directory
ipaddress=$1

# if we can ssh as root into the box and it is on thie network, it deserves what is coming to it
if(`ssh root@$ipaddress`); then
	# remove the permissions
	# scp the permissions zip into the home folder 
	# unzip it
	# set a static ip for the network device
	# change the hostname to 'ddc-node'
	# echo BB-UART1 >> /sys/devices/bone_capemgr.9/slots

	#...
	
	# reboot
else

fi 