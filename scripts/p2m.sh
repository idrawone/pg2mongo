### help
### docker exec -it pg2mongo_mongo_1 bash /p2m.sh 1 2
###

#!/bin/bash

set -m

source /root/.bashrc

if [[ $# -eq 0 || "$1" == "-h" ]]; then
	echo "Usage:"
	echo "  * Outside of the container:"
	echo -e "\tdocker exec -it pg2mongo_mongo_1 bash /p2m.sh 1 2"
	echo "  * Inside of the container:"
	echo -e "\t./`basename $0` 1 2"
	echo "  where '1 2' is the list of the pg2mongo_pg{x}_1 containers"
	exit 0
fi

for i in $@
do
	if [ -p "/tmp/pipe-pg${i}" ]; then
		echo "/tmp/pipe-pg${i} exist"
	else
		mkfifo /tmp/pipe-pg${i}
	fi
	pg_recvlogical -d postgres -h pg2mongo_pg${i}_1 -U postgres --slot w2m_slot${1} --create-slot --plugin=wal2mongo 
	sleep 1;
	pg_recvlogical -d postgres -h pg2mongo_pg${i}_1 -U postgres --slot w2m_slot${i} --start -f /tmp/pipe-pg${i} &
	status=$?
	if [ $status -ne 0 ]; then
		echo "Failed to start my_first_process: $status"
		echo "pg2mongo_pg${i}_1 $status"
	fi

	mongo < /tmp/pipe-pg${i} &
	status=$?
	if [ $status -ne 0 ]; then
		echo "Failed to start my_first_process: $status"
		echo "mongo < /tmp/pipe-pg${i} $status"
	fi
	sleep 1;

done
