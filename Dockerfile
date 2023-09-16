# Copyright (c) 2017, 2023, Oracle and/or its affiliates.
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

FROM oraclelinux:8-slim

ENV VERSION=8.0.34

ARG MYSQL_SERVER_PACKAGE=mysql-cluster-community-server-minimal-${VERSION}
ARG MYSQL_SHELL_PACKAGE=mysql-shell-${VERSION}

# Setup repositories for minimal packages (all versions)
RUN rpm -U http://repo.mysql.com/mysql-cluster-community-minimal-release-el8.rpm \
  && rpm -U http://repo.mysql.com/mysql80-community-release-el8.rpm

# Install server and shell 8.0
RUN microdnf update && echo "[main]" > /etc/dnf/dnf.conf \
  && microdnf install -y --enablerepo=mysql-tools-community $MYSQL_SHELL_PACKAGE \
  && microdnf install -y --disablerepo=ol8_appstream \
   --enablerepo=mysql-cluster80-community-minimal $MYSQL_SERVER_PACKAGE \
  && microdnf clean all \
  && mkdir /docker-entrypoint-initdb.d

ENV MYSQL_UNIX_PORT /var/lib/mysql/mysql.sock

# COPY docker-entrypoint.sh /entrypoint.sh
# COPY healthcheck.sh /healthcheck.sh
# COPY cnf/my.cnf /etc/
# COPY cnf/mysql-cluster.cnf /etc/
# COPY prepare-image.sh /

COPY rootfs/ /

RUN bash /prepare-image.sh && rm -f /prepare-image.sh

VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD /healthcheck.sh
EXPOSE 3306 33060-33061 2202 1186
CMD ["mysqld"]
