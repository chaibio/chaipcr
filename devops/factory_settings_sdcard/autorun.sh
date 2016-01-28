#!/bin/sh

debug=1
BASEDIR=$(dirname $0)

if [ $debug -eq 1 ]
then
	NOW=$(date +"%m-%d-%Y %H:%M:%S")
	log_file=/mnt/booting.log

	echo "Logging boot to: $log_file.. timestamp: $NOW"
	echo "==== New boot at: $NOW" >> $log_file
	sh /mnt/autorun_core.sh  >> $log_file 2>&1
	result=$?
	echo "Boot with logging complete!"
	tail $log_file
else
	sh /mnt/autorun_core.sh
	result=$?
fi

exit $result
