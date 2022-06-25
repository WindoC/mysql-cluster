# windoac/mysql-cluster

forked from [mysql/mysql-docker](https://github.com/mysql/mysql-docker/tree/main/mysql-cluster/8.0)

Most of the setting should be same.

## new add feature for this forked

### Environment add for WAIT_FOR_PEER logic

* `WAIT_FOR_PEER_READY`: true to wait all peer ready before start. Defaults to `true`. 

* `WAIT_FOR_PEER_RETRY`: number of time will retry for wait peer. Defaults to 30. 

* `WAIT_FOR_PEER_DELAY`: time will wait before retry. Defaults to 10. 
   
## how to run in docker swarm

```shell
docker build -t mysql-cluster:8 .
```

```yml
version: "3.7"

networks:

  interconnect:

services:

  management1:
    hostname: management1
    image: mysql-cluster:8
    command: ndb_mgmd
    networks:
      - interconnect
  
  ndb1:
    hostname: ndb1
    image: mysql-cluster:8
    command: ndbd --ndb-nodeid=2
    networks:
      - interconnect

  ndb2:
    hostname: ndb2
    image: mysql-cluster:8
    command: ndbd --ndb-nodeid=3
    networks:
      - interconnect
  
  mysql1:
    hostname: mysql1
    image: mysql-cluster:8
    command: mysqld --ndb-nodeid=4
    networks:
      - interconnect
    ports:
      - 3306:3306
```
