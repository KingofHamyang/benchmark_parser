#!/bin/bash

FILE_SYSTEMS=("ext4" "xfs" "f2fs")
NUM_THREADS=(1 2 4 8)
WORKLOADS=("varmail.f" "fileserver.f")

rm -rf ./output
mkdir ./output

printf "%16s" "File System" >> ./output/result.dat
for wk in ${WORKLOADS[@]}; do
	for tr in ${NUM_THREADS[@]}; do
		printf "%16s" "$wk#$tr" >> ./output/result.dat
	done
done

printf "\n" >> ./output/result.dat

for fs in ${FILE_SYSTEMS[@]}; do
	echo "make filesystem $fs"
	umount /dev/sda6 1>/dev/null
	if [ $fs == ext4 ]; then
		yes | mkfs -t $fs /dev/sda6 1>/dev/null
	else
		mkfs.$fs -f /dev/sda6 1>/dev/null
	fi
	mount /dev/sda6 /home/haseongjun/workspace 1>/dev/null
	printf "%16s" "$fs" >> ./output/result.dat
	for((i=0; i<2; i++)); do
		echo "run for ${WORKLOADS[$i]}"
		for((j=0; j<4; j++)); do
		echo "num_tr ${NUM_THREADS[$j]}"
		# setting num thread
		sed -i "s/nthreads=[0-9]*/nthreads=${NUM_THREADS[$j]}/g" ./${WORKLOADS[$i]}
		ops=`filebench -f ./${WORKLOADS[$i]} |  awk '/IO Summary/ {print $6}'`
		printf "%16f" $ops >> ./output/result.dat
		done
	done
	printf "\n" >> ./output/result.dat
done

