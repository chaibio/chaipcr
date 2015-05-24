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
		dhclient -r $wlan;
		wpa=$(ps ax | grep -e [w]pa_supplicant);
		if [ ! -z "$wpa" ]; then
                     killall wpa_supplicant;
                fi
                sleep 1s;
                sudo wpa_supplicant -Bu -D nl80211 -iwlan0 -c wpa.conf;
                dhclient wlan0;
		status=$(iw $wlan link | ./chkwifi.sh);
                echo $status
        fi
        ;;
        disconnect)
        dhclient -r $wlan;
        killall wpa_supplicant;
        ifconfig $wlan down
        sleep 1s;
        ifconfig $wlan up
        echo "1"
        ;;
        scan)
        command="iwlist $wlan scan | ./lswifi.sh"
        eval $command
        ;;
        up)
        ifconfig $wlan up
        echo "{'status': 'done'}"
        ;;
        down)
        ifconfig $wlan down
        echo "{'status': 'done'}"
        ;;
        status)
        iw $wlan link | ./chkwifi.sh -a
        ;;
	statusmin)
        iw $wlan link | ./chkwifi.sh
esac

