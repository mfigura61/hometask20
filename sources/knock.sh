#!/bin/bash
HOST=$1
shift
for PORT in "$@"
do
	nmap -Pn --max-retries 0 -p $PORT $HOST
done