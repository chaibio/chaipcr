#!/bin/bash

#isuint_Bash() { (( 10#$1 >= 0 )) 2>/dev/null ;}

for p in /proc/*
do
#	part1=$(dirname "$p")
	procid=$(basename "$p")
	if ! expr -- "$procid" + 0 > /dev/null 2>&1
	then
#	    echo "Process $procid"
#	else
#	    echo "isn't a number $procid"
	    continue
	fi

	opened_files_path=$p/fd/
	if [ ! -d $opened_files_path ]
	then
#		echo "$opened_files_path No opened files "
		continue
	fi

#	echo "ls $opened_files_path | wc -l"
	opened_files_count=$(ls $opened_files_path | wc -l)
	if [ $opened_files_count -gt 0 ]
	then
		nm=$(cat $p/cmdline)
		echo -e "${opened_files_count}\t${procid}\t$nm"
	fi

	#echo "\t $opened_files_count"

#	if isuint_Bash $p
#	then
#		echo "Process: $p"
#	fi

done

exit 0
