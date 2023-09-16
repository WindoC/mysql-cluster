# windoac/mysql-cluster

forked from [mysql/mysql-docker](https://github.com/mysql/mysql-docker/tree/main/mysql-cluster/8.0)

Most of the setting should be same.

Why the fork?
- ARM supported
- data persistence

## build your own

### build

```shell
docker build -t mysql-cluster .
```

### test

```shell
docker network create mysql-cluster
docker run -d --name ndbmgm --hostname ndbmgm --net mysql-cluster --no-healthcheck mysql-cluster ndb_mgmd
docker run -d --name ndb1 --hostname ndb1 --net mysql-cluster --no-healthcheck mysql-cluster ndbd
docker run -d --name ndb2 --hostname ndb2 --net mysql-cluster --no-healthcheck mysql-cluster ndbd
docker run -d --name mysql1 --hostname mysql1 --net mysql-cluster --no-healthcheck mysql-cluster mysqld
docker run -d --name mysql2 --hostname mysql2 --net mysql-cluster --no-healthcheck mysql-cluster mysqld

docker ps | grep mysql-cluster

docker logs -f --tail 100 ndbmgm
docker logs -f --tail 100 ndb1
docker logs -f --tail 100 ndb2
docker logs -f --tail 100 mysql1
docker logs -f --tail 100 mysql2

docker exec -it ndbmgm ndb_mgm
show

docker ps | grep mysql-cluster | cut -d ' ' -f 1 | xargs -n1 docker stop
docker ps -a | grep mysql-cluster | cut -d ' ' -f 1 | xargs -n1 docker rm
docker network rm mysql-cluster

```

## how to run in docker swarm

Must disable the `healthcheck` to make the hostname can be detect between each node.

```yaml
version: "3.7"

volumes:

  ndbmgm_data:
  ndb1_data:
  ndb2_data:
  mysql1_data:
  mysql2_data:


services:

  ndbmgm:
    image: ghcr.io/windoc/mysql-cluster:latest
    command: ndb_mgmd
    hostname: ndbmgm
    healthcheck:
      disable: true
    volumes:
      - ndbmgm_data:/data
    # ports:
    #   - 1186:1186
    environment:
      TZ : Asia/Hong_Kong
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any

  ndb1:
    image: ghcr.io/windoc/mysql-cluster:latest
    command: ndbd
    hostname: ndb1
    healthcheck:
      disable: true
    volumes:
      - ndb1_data:/data
    environment:
      TZ : Asia/Hong_Kong
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any

  ndb2:
    image: ghcr.io/windoc/mysql-cluster:latest
    command: ndbd
    hostname: ndb2
    healthcheck:
      disable: true
    volumes:
      - ndb2_data:/data
    environment:
      TZ : Asia/Hong_Kong
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any

  mysql1:
    image: ghcr.io/windoc/mysql-cluster:latest
    command: mysqld
    hostname: mysql1
    healthcheck:
      disable: true
    volumes:
      - mysql1_data:/data
    # ports:
    #   - 3306:3306
    environment:
      TZ : Asia/Hong_Kong
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any

  mysql2:
    image: ghcr.io/windoc/mysql-cluster:latest
    command: mysqld
    hostname: mysql2
    healthcheck:
      disable: true
    volumes:
      - mysql2_data:/data
    # ports:
    #   - 3306:3306
    environment:
      TZ : Asia/Hong_Kong
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: any
```


reminder 1: please remember to setup 'volumes' base on your need.

```yaml
volumes:

  # example 1 glusterfs
  ndbmgm_data:
    driver: glusterfs
    name: "docker-volume/ndbmgm/data"

  # example 2 nfs
  ndbmgm_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.0.100,nolock,rw
      device: ":/nfsdata/ndbmgm/data"
  
  # example 3 local folder
  ndbmgm_data:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /data/ndbmgm

```

reminder 2: setup deploy placement constraints control mysql role running in whick docker_node.

```yaml
    deploy:
      placement:
        constraints:
          - "node.labels.mysql-cluster-ndbmgm==true"
```

```shell
# set label for node
docker node update --label-add mysql-cluster-ndbmgm==true docker_node
```

### mysql ROOT password

search the keywork `GENERATED ROOT PASSWORD:` in mysql1 and mysql2 to get the root password of each mysqld node.

Then docker exec `bash` to mysqld node to change the root password. (id needed)
