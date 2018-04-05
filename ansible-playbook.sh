#!/bin/bash

TEST=

if [ "$#" -lt 2 ]; then
	echo "ERROR: Usage $0 <LIMIT-HOST> <YML> [<OPTION>] "
	exit 255
fi

if [ ! -f "$2" ]; then
	echo "ERROR: file '$2' cannot be found."
	exit 254
fi

$TEST ansible-playbook \
	${@:3} \
	--limit $1 \
	--ask-vault-pass \
	-K \
	-vvv \
	-s \
	$2 