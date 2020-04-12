#!/bin/bash
set -e

docker-compose -f service-compose.yml up -d

if [[ $# -eq 0 || $1 -lt 15 ]]; then
	echo "Wait 15 sec for database startup ..."
	sleep 15;
else
	echo "Wait $1 sec for database startup ..."
	sleep $1;
fi
docker exec -it pg2mongo_mongo_1 bash /p2m.sh 1 2
echo -e "\nPostgres to MongoDB logical replication slots setup is done\n"
