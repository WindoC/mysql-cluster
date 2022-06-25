# windoac/mysql-cluster

forked from [mysql/mysql-docker](https://github.com/mysql/mysql-docker/tree/main/mysql-cluster/8.0)

Most of the setting should be same.
   
## how to run in docker swarm

### build your own

```shell
docker build -t mysql-cluster:8 .
```

### or use mine

https://hub.docker.com/repository/docker/windoac/mysql-cluster

```shell
docker pull windoac/bind-webmin:mysql-cluster:8
```

### prepare

suppose request you have maximum 5 servers or minimum 3 servers.

5 servers : of cause maximum is 1 node 1 host
3 servers : ndb_mgmd on 1 host , ( 1 ndbd and 1 mysqld 1 host ) x 2

1. according your ip of the host. prepaid the `--add-host` list.

for example, ip 192.168.0.21 ~ 25 use for the cluster
```shell
addhosts=$(cat << EOF
--add-host ndbmgm:192.168.0.21
--add-host   ndb1:192.168.0.22
--add-host   ndb2:192.168.0.23
--add-host mysql1:192.168.0.24
--add-host mysql2:192.168.0.25
EOF
)
```

2. choose your image
```shell
image=mysql-cluster:8
```
or
```shell
image=windoac/bind-webmin:mysql-cluster:8
```

3. set therole

Base on the mysql-cluster node role you prepare to start/run
```shell
therole=ndb_mgmd
therole=ndbd
therole=mysqld
```

4. storage location

the data and config you would like to store. Can you current path or some others.
```shell
# current path
datapath=$(pwd)
# or some others ex: /data
datapath=/data
```

5. prepare role data location.

```shell
roledatapath=$datapath/$therole
mkdir -p $roledatapath/config
mkdir -p $roledatapath/data
```
(Use sudo, chown and chmod if need)

6. download my.cnf and mysql-cluster.cnf if need.

```shell
curl https://raw.githubusercontent.com/WindoC/mysql-cluster/main/cnf/my.cnf -o $roledatapath/config/my.cnf
curl https://raw.githubusercontent.com/WindoC/mysql-cluster/main/cnf/mysql-cluster.cnf -o $roledatapath/config/mysql-cluster.cnf
```

Add them for your need.

```shell
configvolumes=$(cat << EOF
-v $roledatapath/config/my.cnf:/etc/my.cnf
-v $roledatapath/config/mysql-cluster.cnf:/etc/mysql-cluster.cnf
EOF
)
```

7. volume to store data if need

```shell
datavolumes="-v $roledatapath/data:/data"
```

8. start/run the container

```shell
docker run -d --name ndbmgm --net host $addhosts $configvolumes $datavolumes $image $therole
docker run -d --name ndb1   --net host $addhosts $configvolumes $datavolumes $image $therole
docker run -d --name ndb2   --net host $addhosts $configvolumes $datavolumes $image $therole
docker run -d --name mysql1 --net host $addhosts $configvolumes $datavolumes $image $therole
docker run -d --name mysql2 --net host $addhosts $configvolumes $datavolumes $image $therole
```
