#!/bin/bash

PROGRAM="sysbench"

if ! command -v ${PROGRAM} >/dev/null; then
	sudo apt update
	sudo apt install sysbench >/dev/null
fi

read -r -p "How many times would you like to run? " NUM_RUNS
[ "$(whoami)" == "root" ] || { echo "Must be run as sudo!"; exit 1; }

vcgencmd measure_temp
vcgencmd get_config int | grep arm_freq
vcgencmd get_config int | grep core_freq
vcgencmd get_config int | grep sdram_freq
vcgencmd get_config int | grep gpu_freq
printf "sd_clock="
grep "actual clock" /sys/kernel/debug/mmc0/ios 2>/dev/null | awk '{printf("%0.3f MHz", $3/1000000)}'
echo -e "\n"

for (( run=1; run<=$NUM_RUNS; run++ ))
do
	echo -e "*********"
	echo -e "Run $run"
	echo -e "*********\n"
	echo -e "Running CPU test...\n"

	sysbench --num-threads=4 --validate=on --test=cpu --cpu-max-prime=10000 run | grep 'total time:\|min:\|avg:\|max:' | tr -s [:space:]
	vcgencmd measure_temp
	echo -e ""
