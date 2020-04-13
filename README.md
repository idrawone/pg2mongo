# pg2mongo


#### Prerequisite 
* Install Docker by refer to https://docs.docker.com/get-docker/
* (optional) psql (12.2) and mongo (4.2.5) need to be installed on local machine, if using them to connect containers from local mapping ports

### Setup with scripts
#### 1. clone repo
git clone https://github.com/idrawone/pg2mongo.git 

#### 2. build images mongod:4.25 and postgres:12.2
```
cd pg2mongo
./build-images.sh
```

#### 3. start container and setup logical replication slots on `pg2mongo_mongo_1`
```
./start.sh  30
```

#### 4. generate databse traffic on containers `pg2mongo_pg1_1` and `pg2mongo_pg2_1`
```
$ docker exec -it pg2mongo_pg1_1 bash /data_gen.sh
$ docker exec -it pg2mongo_pg2_1 bash /data_gen.sh
```

#### 4. login `pg2mongo_mongo_1` to check data replicated
```
$ docker exec -it pg2mongo_mongo_1 bash
[root@a641d6c2cbb4 /]# mongo
> show dbs;
admin                         0.000GB
config                        0.000GB
local                         0.000GB
mycluster_postgres_w2m_slot1  0.005GB
mycluster_postgres_w2m_slot2  0.005GB
> use mycluster_postgres_w2m_slot1
switched to db mycluster_postgres_w2m_slot1
> show collections
pgbench_accounts
pgbench_branches
pgbench_tellers
> db.pgbench_accounts.count()
174973
> use mycluster_postgres_w2m_slot2
switched to db mycluster_postgres_w2m_slot2
> db.pgbench_accounts.count()
175191
```

#### 5. stop containers
```
./stop.sh
```


### Setup manually
#### build the images
```
$ git clone https://github.com/idrawone/pg2mongo.git
$ cd postgres/
$ docker build -t postgres:12.2 .
$ cd ../mongodb/
$ docker build -t mongo:4.2.5 .
```

#### create a dedicated docker network
```
$ docker network create --driver bridge p2m-network
$ docker network ls
```

#### create volumes for postgres instance and mongodb instance
```
$ docker volume create pg1data
$ docker volume create mgdata
$ docker volume ls
```

#### build containers without volume
```
$ docker run --name pg1 --network p2m-network -d postgres:12.2
$ docker run --name mongo --network p2m-network -p 27017:27017 -d mongo:4.2.5
$ docker ps
```

#### build containers with volume
```
$ docker run --name pg1 --network p2m-network -v pg1data:/var/lib/pgsql/12/data/ -d postgres:12.2
$ docker run --name mongo --network p2m-network -v mgdata:/data/db -d mongo:4.2.5
$ docker ps
```

#### build containers with volume and map the ports to localhost
```
$ docker run --name pg1 --network p2m-network -v pg1data:/var/lib/pgsql/12/data/ -p 5432:5432 -d postgres:12.2
$ docker run --name mongo --network p2m-network -v mgdata:/data/db -p 27017:27017 -d mongo:4.2.5
$ docker ps
```

#### connect to containers using the port mapped to localhost
```
$ psql -h localhost -U wal2mongo --password
$ mongo --host localhost --port 27017
```

#### connect to containers directly
```
$ docker run -it --rm --network p2m-network postgres:12.2 psql -h pg1 -U wal2mongo --password
```

#### log into to containers and perform some check
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
fa0a79d5d64b        mongo:4.2.5         "/usr/bin/mongod --b…"   7 minutes ago       Up 7 minutes        0.0.0.0:27017->27017/tcp   mongo
26d4424dd115        postgres:12.2       "/usr/pgsql-12/bin/p…"   7 minutes ago       Up 7 minutes        0.0.0.0:5432->5432/tcp     pg1

$ docker exec -it pg1 bash
bash-4.2$ export PATH=/usr/pgsql-12/bin:$PATH
bash-4.2$ USE_PGXS=1 make installcheck-force
or 
bash-4.2$ USE_PGXS=1 make installcheck-force CLANG=/usr/bin/clang with_llvm=no
$ docker exec -it mongo bash
[root@fa0a79d5d64b /]# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 05:52 ?        00:00:06 /usr/bin/mongod --bind_ip_all
root        43     0  1 06:09 pts/0    00:00:00 bash
root        57    43  0 06:09 pts/0    00:00:00 ps -ef
```

### Notes: below commands is for demo purpose, don't run these commands unless "the results" is what you expected.
#### stop and remove containers (all containers will be removed)
```
$ docker container stop $(docker container ls -aq)
$ docker container rm $(docker container ls -aq)
```

#### remove all images (all images will be removed)
```
$ docker image prune -a
$ docker network prune
$ docker volume prune
$ docker images -a
```

