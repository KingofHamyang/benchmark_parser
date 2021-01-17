#!/bin/bash

FILE_SYSTEMS=("ext4" "xfs" "f2fs")
WRITE_TYPE=(0 1 4)
SYNC_TYPE=(8 8 2)

rm ./output/result.dat
for fs in ${FILE_SYSTEMS[@]}; do
	umount /dev/sda6 1>/dev/null
	if [ $fs == ext4 ]; then
		yes | mkfs -t $fs /dev/sda6 1>/dev/null
	else
		mkfs.$fs -f /dev/sda6 1>/dev/null
	fi
	mount /dev/sda6 /home/haseongjun/workspace 1>/dev/null
	printf "%8s" "$fs" >> "./output/result.dat"
	for((i=0; i<3; i++)); do
		echo "$fs, $i start"
		date
		kb_per_sec=`./mobibench -p /home/haseongjun/workspace -f 1048576  -a ${WRITE_TYPE[$i]} -y ${SYNC_TYPE[$i]} | awk '/[TIME]/ {print $8}'`
		printf "%16f" "$kb_per_sec" >> "./output/result.dat"
		printf " KB/sec" >> "./output/result.dat"
		rm -rf /home/haseongjun/workspace/*
		echo "end"
		date
	done
	printf "\n" >> "./output/result.dat"
done


