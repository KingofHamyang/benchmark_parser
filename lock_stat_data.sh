#!/bin/bash

FILE_SYSTEM=("ext4" "xfs" "f2fs")

for fs in ${FILE_SYSTEM[@]}; do
	umount /dev/sda6 1>/dev/null
        if [ $fs == ext4 ]; then
                yes | mkfs -t $fs /dev/sda6 1>/dev/null
        else
                mkfs.$fs -f /dev/sda6 1>/dev/null
        fi
	mount /dev/sda6 /home/haseongjun/work_dir 1>/dev/null

	echo 0 > /proc/lock_stat
	echo 1 > /proc/sys/kernel/lock_stat

	filebench -f ./varmail.f

	echo 0 > /proc/sys/kernel/lock_stat

	rm ./output.$fs.lockstat.dat
	while read line
	do
	       	name=`echo $line | awk -F ":" '{print $1}'`
		field=`echo $line | awk -F ":" '{print $2}' | awk '{print $5}'`
		printf "%16f %16s\n" "$field" "$name" >> ./output.$fs.lockstat.temp
	
	done < <(grep :  /proc/lock_stat)

	sort -r ./output.$fs.lockstat.temp | head > ./output.$fs.lockstat.dat
	rm ./output.$fs.lockstat.temp
done
