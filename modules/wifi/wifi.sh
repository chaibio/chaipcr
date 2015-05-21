#!/bin/bash
wlan="wlan0"

case "$1" in
        connect)
        if [ -z "$2" ]
                then
                        echo  "SSID cannot be empty"
                else
                SSID=$2;
                pass=$3;
                echo "ctrl_interface=/var/run/wpa_supplicant \n" > wpa.conf
                wpa_passphrase "$2" "$3" >> wpa.conf
                killall wpa_supplicant;
                sleep 1s;
                sudo wpa_supplicant -Bu -D nl80211 -iwlan0 -c wpa.conf -dd
                dhclient wlan0;
        fi
        ;;
        disconnect)
        dhclient -r $wlan
        ;;
        scan)
        command="iwlist $wlan scan | ./lswifi.sh"
        eval $command
        ;;
        up)
        ifconfig $wlan up
        ;;
        down)
        ifconfig $wlan down
        ;;
esac

