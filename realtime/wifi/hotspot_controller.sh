#!/bin/bash

interface=wlan0
hotspotssid=Chaibio
hotspotkey=password
#echo 2 is $2
if [[ "$2" == "stop" ]] && [ -n "$1" ]
then
	echo disabling hotspot on interface $1
	if [ -e /sdcard/upgrade/interfaces.latest_wifi_settings ]
	then
		cp /sdcard/upgrade/interfaces.latest_wifi_settings /etc/network/interfaces
		systemctl disable hostapd
		/sbin/ifdown $1
		/sbin/ifup $1
	fi
	exit 0
fi

#echo 2 is $2
if [[ "$2" == "wifiselect" ]] && [ -n "$1" ]
then
        echo selecting to go wifi on interface $1
        systemctl disable hostapd

        if [ -e /sdcard/upgrade/interfaces.latest_wifi_settings ]
        then
                cp /sdcard/upgrade/interfaces.latest_wifi_settings /etc/network/interfaces
	else
                cp /root/chaipcr/deploy/wifi/interfaces.empty.template /etc/network/interfaces
        fi

        /sbin/ifdown $1
        /sbin/ifup $1

        exit 0
fi

if [[ "$2" == "hotspotdeactivate" ]] && [ -n "$1" ]
then
        echo selecting to go wifi on interface $1
        systemctl disable hostapd

        if [ -e /sdcard/upgrade/interfaces.latest_hotspot_settings ]
        then
                cp /sdcard/upgrade/interfaces.latest_hotspot_settings /etc/network/interfaces
        else
                cp /root/chaipcr/deploy/wifi/interfaces.empty.template /etc/network/interfaces
        fi

        /sbin/ifdown $1
        /sbin/ifup $1

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
        systemctl enable hostapd

        /sbin/ifdown $1
        /sbin/ifup $1

        exit 0
fi


if [ -z $3 ] || [ -z $1 ] || [ -z $2 ]
then
	echo ""
	echo "Usage error"
	echo "Usage: hotspot_controller.sh <Interface> <Hotspot SSID> <Hotspot key>"
        echo "Example: hotspot_controller.sh wlan0 Chaibio password"
	echo " "
	exit 1
else
	interface=$1
	hotspotssid=$2
	hotspotkey=$3
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

systemctl enable hostapd

/sbin/ifdown $interface
/sbin/ifup $interface

cp /etc/network/interfaces /sdcard/upgrade/interfaces.latest_hotspot_settings

exit 0

