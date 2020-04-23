#!/bin/bash
set -m

PGDATA=/var/lib/pgsql/12/data
VERFILE=$PGDATA/PG_VERSION

export PATH=/usr/pgsql-12/bin:$PATH

if [ -f "$VERFILE" ]; then
		echo "$VERFILE exist"
else
		initdb -D $PGDATA
		psql --command "CREATE USER wal2mongo WITH SUPERUSER PASSWORD 'wal2mongo';"
		createdb -O wal2mongo wal2mongo

		echo "listen_addresses='*'" >> $PGDATA/postgresql.conf
		echo "wal_level = logical"  >> $PGDATA/postgresql.conf
		echo "host  all  all  0.0.0.0/0  trust" >> $PGDATA/pg_hba.conf
fi

postgres -D $PGDATA
