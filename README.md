# pg2mongo

#### Prerequisite 
* install Docker

#### build the images
```
docker build -t postgres:12.2 .
docker build -t mongod:4.2.5 .
```

#### create a dedicated docker network
```
docker network create --driver bridge p2m-network
docker network ls
```

#### create volumes for postgres instance and mongodb instance
```
docker volume create pg1data
docker volume create mgdata
docker volume ls
```

#### build containers without volume
```
docker run --name pg1 --network p2m-network -d postgres:12.2
docker run --name mongo --network p2m-network -p 27017:27017 -d mongo:4.2.5
```

#### build containers with volume
```
docker run --name pg1 --network p2m-network -v pgdata:/var/lib/pgsql/12/data/ -d postgres:12.2
docker run --name mongo --network p2m-network -v mgdata:/data/db -d mongo:4.2.5
```

#### build containers with volume and map the ports to localhost
```
docker run --name pg1 --network p2m-network -v pgdata:/var/lib/pgsql/12/data/ -p 5432:5432 -d postgres:12.2
docker run --name mongo --network p2m-network -v mgdata:/data/db -p 27017:27017 -d mongo:4.2.5
```

#### connect to containers using the port mapped to localhost
```
psql -h localhost -U wal2mongo --password
mongo --host localhost --port 27017
```

#### connect to containers directly
```
docker run -it --rm --network p2m-network postgres:12.2 psql -h pg1 -U wal2mongo --password
```

#### stop and remove containers
```
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)
```

#### remove all images
```
docker image prune -a
docker network prune
docker volume prune
docker images -a
```

