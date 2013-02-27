#!/bin/bash


log_file=/home/xl0/work/simple-backup/backup.log

function do_backups {
	echo "starting backup on `date`"
	for location in `grep -v ^# $1`
	do
		echo $location

		direction=`echo $location | cut -d: -f1`
		echo "Direction: $direction"

		if [ $direction = "G" ]
		then
			# Get data from a remote host
			host=`echo $location | cut -d: -f2`
			port=`echo $location | cut -d: -f3`
			src_dir=`echo $location | cut -d: -f4`
			dst_dir_base=`echo $location | cut -d: -f5`

			echo "Host: $host"
			echo "Port: $port"
			echo "Src directory: $src_dir"
			echo "Dst directory base: $dst_dir_base"

			norm_src=`echo $src_dir | tr / -`
			dst_dir="$dst_dir_base/${host}${norm_src}"

			echo "Dst directory: $dst_dir"

			rsync -ve "ssh -p $port" -a $host:$src_dir/ $dst_dir
		elif [ $direction = "P" ]
		then
			# Push data to a remote host
			src_dir=`echo $location | cut -d: -f 2`
			host=`echo $location | cut -d: -f 3`
			port=`echo $location | cut -d: -f 4`
			dst_dir_base=`echo $location | cut -d : -f 5`

			echo "Host: $host"
			echo "Port: $port"
			echo "Src directory: $src_dir"
			echo "Dst directory base: $dst_dir_base"


			norm_src=`echo $src_dir | tr / -`

			dst_dir=$dst_dir_base/`hostname`$norm_src

			echo "Dst directory: $dst_dir"

			rsync -ve "ssh -p $port" -a $src_dir $host:$dst_dir
		else
			echo "WTF?"
		fi

	done
}


for location in $*
do
	do_backups $location >> $log_file 2>&1
done
