#!/bin/bash

interface=$1
if [ -z $interface ]
then
	echo "usage example: ifup wlan0"
	exit 1
fi

defined=$(grep "$interface" /etc/network/interfaces)
if [ -z "$defined" ]
then
	echo interface $interface not defined
	cp /etc/network/interfaces /tmp/ifup.interface.bak
        echo "# ifup temprary setup" >> /etc/network/interfaces
	echo "allow-hotplug wlan0" >> /etc/network/interfaces
        echo "iface wlan0 inet dhcp" >> /etc/network/interfaces
fi

/sbin/ifup $interface
retval=$?
if [ -z "$defined" ]
then
        cp /tmp/ifup.interface.bak /etc/network/interfaces
fi

exit $retval
