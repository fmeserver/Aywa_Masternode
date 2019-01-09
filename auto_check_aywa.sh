#!/bin/sh
# find the daemon process
process=`ps -ef|grep 'aywad -daemon'|grep -v grep`

# check and restart
if [ $? -ne 0 ]
then
	# daemon process is not exist,restart it,If the file is not ~/aywa/aywad, Please modify the correct location
	echo "aywa restarting ... on `date "+%Y-%m-%d %H:%M:%S"` "
	~/aywa/aywad -daemon
else
	echo "aywa is ok. `date "+%Y-%m-%d %H:%M:%S"` "
fi
