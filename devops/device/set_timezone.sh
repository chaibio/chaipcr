#!/bin/bash

if [ -e /tmp/Timezone ]
then
	echo timezone already set
else
	timedatectl
	wget http://ip-api.com/line?fields=timezone --timeout=10 -O/tmp/Timezone
	if [ -e /tmp/Timezone ]
	then
		echo Setting timezone
		timedatectl set-timezone $(cat /tmp/Timezone)
		timedatectl
	fi
fi
