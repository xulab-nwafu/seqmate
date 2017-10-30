#!/bin/bash

files=("/home/xulab/bin" "/home/xulab/sf" "/disk/xulab/db")

if [ `whoami` != 'root' ]; then
	echo "Permission denied!"
	exit
fi

function protection {
	for file in  ${files[@]}; do
		chattr +i $file
	done
}

function deprotection {
	for file in  ${files[@]}; do
		chattr -i $file
	done
}

function usage {
	echo
	echo "Usage:"
	echo "$0 on|off"
	echo
	exit
}

if [ $# != 1 ]; then
	usage
fi

case $1 in
	"on")
		protection
		;;
	"off")
		deprotection
		;;
	*)
		usage
		;;
esac

