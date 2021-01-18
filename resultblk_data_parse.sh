#!/bin/bash

FILE_SYSTEM=("ext4" "xfs" "f2fs")

for fs in ${FILE_SYSTEM[@]}; do
	total=0
	sum=0
	printf "%s\n" "$fs"
	printf "%s\t%s\n" "Count" "I/O KB"
	while read line
	do
		arr=($line)
		if [ "${arr[1]}" = 'C' ]; then
			printf "%d\t" ${arr[0]}
			printf "%d\n" ${arr[2]}
			kb=${arr[0]}
			count=${arr[2]}
			total=`expr $sum + $kb \* $count`
			sum=$total
		fi
	done < <(cat blkresult_$fs | sort | uniq -c)
	printf "Total I/O size in KB %d\n\n" $sum
done

