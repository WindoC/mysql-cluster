#!/bin/bash
# Copyright (c) 2021, Oracle and/or its affiliates.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA


# Create directories needed by mysqld and make them writable by group 0
mysql_dirs="/var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/run/mysqld /usr/mysql-cluster"

for dir in $mysql_dirs; do
    mkdir -p $dir
    chmod g+rwx $dir
    chgrp -R 0 $dir
done

# create volume folder
mkdir -p /data
chmod g+rwx /data
chgrp -R 0 /data

# chmod
chmod 755 /etc
chmod 640 /etc/my.cnf 
chmod 640 /etc/mysql-cluster.cnf
chmod 755 /entrypoint.sh
chmod 755 /healthcheck.sh

linkifnotexist () {
    $srcpath=$1
    $dstpath=$1
    if [ ! -f $dstpath ] ; then
        if [ -f $srcpath ] ; then
            ln -s $srcpath $dstpath
        fi
    fi
}

# makesure bash path
linkifnotexist /usr/bin/bash /bin/bash
