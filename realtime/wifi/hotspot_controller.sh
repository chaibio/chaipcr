#!/bin/bash

# to disable this script please uncomment next two lines
echo $@ >> /tmp/hotspot_controller.log
#echo OK
#exit 0

interface=wlan0
hotspotssid=Chaibio
hotspotkey=password
#echo 2 is $2

if [[ "$2" == "checkhotspot" ]] && [ -n "$1" ]
then
        echo checking hotspot status
	check_wifi_settings=$(grep "hostapd" /etc/network/interfaces)
	if [ -n "$check_wifi_settings" ]
	then
        	echo checking hotspot service status
	        check_wifi_settings=$(service hostapd status | grep Active)
		if [ -n "$check_wifi_settings" ]
        	then
			echo "OK: Hotspot active"
			exit 0
		else
                        echo "KO: Hotspot service inactive"
			exit 0
		fi
	else
                echo "KO: Missing hotspot settings"
		exit 0
	fi

	echo "KO"
	exit 0
fi

if [[ "$2" == "stop" ]] && [ -n "$1" ]
then
	echo disabling hotspot on interface $1
	if [ -e /sdcard/upgrade/interfaces.latest_wifi_settings ]
	then
		cp /sdcard/upgrade/interfaces.latest_wifi_settings /etc/network/interfaces
		systemctl stop hostapd
		service hostapd stop
		/sbin/ifdown $1
		/sbin/ifup $1
	fi
        echo "OK"
	exit 0
fi

#echo 2 is $2
if [[ "$2" == "wifiselect" ]] && [ -n "$1" ]
then
        echo selecting to go wifi on interface $1
        systemctl stop hostapd
        service hostapd stop

        if [ -e /sdcard/upgrade/interfaces.latest_wifi_settings ]
        then
                cp /sdcard/upgrade/interfaces.latest_wifi_settings /etc/network/interfaces
	else
                cp /root/chaipcr/deploy/wifi/interfaces.empty.template /etc/network/interfaces
        fi

        /sbin/ifdown $1
        /sbin/ifup $1
	retval=$?

	echo "OK"
        exit $retval
fi

if [[ "$2" == "hotspotdeactivate" ]] && [ -n "$1" ]
then
	echo Removing wifi settings, and return to empty interfaecs.
        echo selecting to go wifi on interface $1
        systemctl stop hostapd
	service hostapd stop

        cp /root/chaipcr/deploy/wifi/interfaces.empty.template /etc/network/interfaces

        /sbin/ifdown $1
 #       /sbin/ifup $1

	echo OK

        exit 0
fi

if [[ "$2" == "hotspotselect" ]] && [ -n "$1" ]
then
        echo selecting to go on hotspot on interface $1

        if [ -e /sdcard/upgrade/interfaces.latest_hotspot_settings ]
        then
                cp /sdcard/upgrade/interfaces.latest_hotspot_settings /etc/network/interfaces
        else
                cp /root/chaipcr/deploy/wifi/interfaces.empty.template /etc/network/interfaces
        fi
        systemctl start hostapd
        service hostapd start

        /sbin/ifdown $1
        /sbin/ifup $1

	echo OK

        exit 0
fi


if [ -z $3 ] || [ -z $1 ] || [ -z $2 ] || [ -z $4 ] 
then
	echo ""
	echo "Usage error"
	echo "Usage: hotspot_controller.sh <Interface> hotspotActivate <Hotspot SSID> <Hotspot key>"
        echo "Example: hotspot_controller.sh wlan0 Chaibio password"
	echo " "
	exit 1
fi

if [[ "$2" == "hotspotActivate" ]] && [ -n "$1" ] && [ -n "$4" ] &&[ -n "$2" ] &&[ -n "$3" ]
then
	interface=$1
	hotspotssid=$3
	hotspotkey=$4
else
        echo "Usage error"
	exit 1
fi

echo Setting up wifi hotspot using the following settings
echo Interface: $interface
echo SSID: $hotspotssid
echo Key: $hotspotkey

cp /etc/network/interfaces /tmp/ --backup=numbered		# for debug
cp /etc/hostapd/hostapd.conf /tmp/ --backup=numbered            # for debug

# backup wifi settings
check_wifi_settings=$(grep "wpa-psk" /etc/network/interfaces)
if [ -n "$check_wifi_settings" ]
then
	echo backing up latest wifi settings
	cp /etc/network/interfaces /sdcard/upgrade/interfaces.latest_wifi_settings
fi

# Settingup hotspot
systemctl stop hostapd
service hostapd stop
ifconfig $interface down

cp /root/chaipcr/deploy/wifi/hostapd.conf.template /etc/hostapd/hostapd.conf
cp /root/chaipcr/deploy/wifi/interfaces.hotspot.template /etc/network/interfaces

sed -i "s/NAMEOFNETWORK/${hotspotssid}/g" /etc/hostapd/hostapd.conf || true
sed -i "s/WIRELESSKEY/${hotspotkey}/g" /etc/hostapd/hostapd.conf || true
sed -i "s/INTERFACE/${interface}/g" /etc/hostapd/hostapd.conf || true
sed -i "s/INTERFACE/${interface}/g" /etc/network/interfaces || true

update_test=$(grep "CHAIBIO" /etc/dnsmasq.conf)
if [ -z "$update_test" ]
then
        echo "# ">>/etc/dnsmasq.conf
	echo "# CHAIBIO Hotspot settings">>/etc/dnsmasq.conf
	echo "interface=$interface">>/etc/dnsmasq.conf
	echo "dhcp-range=10.0.0.2,10.0.0.20,255.255.255.0,24h">>/etc/dnsmasq.conf
fi

pid=$(cat /run/hostapd.wlan0.pid)
kill -9 $pid
sleep 1

/usr/sbin/hostapd -B -P /run/hostapd.wlan0.pid /etc/hostapd/hostapd.conf
if [ $? -ne 0 ]
then
	sleep 1
	/usr/sbin/hostapd -B -P /run/hostapd.wlan0.pid /etc/hostapd/hostapd.conf
	if [ $? -ne 0 ]
	then
	        sleep 1
        	/usr/sbin/hostapd -B -P /run/hostapd.wlan0.pid /etc/hostapd/hostapd.conf
	fi
fi

ifconfig $interface up
systemctl start hostapd
service hostapd start

#/sbin/ifdown $interface
#/sbin/ifup $interface

cp /etc/network/interfaces /sdcard/upgrade/interfaces.latest_hotspot_settings

echo OK

exit 0

