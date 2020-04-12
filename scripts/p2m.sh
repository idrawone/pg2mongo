#!/bin/bash

set -x

source /root/.bashrc

for i in $@
do
	if [ -p "/tmp/pipe-pg${i}" ]; then
		echo "/tmp/pipe-pg${i} exist"
	else
		mkfifo /tmp/pipe-pg${i}
	fi
	pg_recvlogical -d postgres -h pg2mongo_pg${i}_1 -U postgres --slot w2m_slot${1} --create-slot --plugin=wal2mongo 
	pg_recvlogical -d postgres -h pg2mongo_pg${i}_1 -U postgres --slot w2m_slot${i} --start -f /tmp/pipe-pg${i} &
	mongo < /tmp/pipe-pg${i} &
done
