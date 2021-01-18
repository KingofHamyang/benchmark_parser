#!/bin/bash

FILE_SYSTEMS=("ext4" "xfs" "f2fs")
MOBIBENCH_PATH=/home/haseongjun/Mobibench/shell # set your own path of Mobibench
BENCHMARK_WORK_DIR=/home/haseongjun/workspace # set your own path for mobibench
file_size=1048576

rm -rf ./output
mkdir ./output


for fs in ${FILE_SYSTEMS[@]}; do
	echo "make filesystem $fs"
	umount /dev/sda6 1>/dev/null
	if [ $fs == ext4 ]; then
		yes | mkfs -t $fs /dev/sda6 1>/dev/null
	else
		mkfs.$fs -f /dev/sda6 1>/dev/null
	fi
	mount /dev/sda6 $BENCHMARK_WORK_DIR 1>/dev/nul

	blktrace -d /dev/sda6 -o ./output/result.dat -a complete & PID_BLKTRACE=$!
	$MOBIBENCH_PATH/mobibench -p $BENCHMARK_WORK_DIR -f $file_size -a 4 -y 2
	kill $PID_BLKTRACE
	wait $PID_BLKTRACE
	blkparse -f "%2a %10N\n" -i ./output/result.dat -o blkresult_$fs

done
