FROM centos:centos7
MAINTAINER The CentOS Project <cloud-ops@centos.org>

RUN yum -y update; yum clean all
RUN yum -y install epel-release yum-utils sudo net-tools which; yum clean all

COPY mongodb.repo /etc/yum.repos.d/

RUN yum -y install mongodb-org-4.2.5 mongodb-org-server-4.2.5 	\
		mongodb-org-shell-4.2.5 mongodb-org-mongos-4.2.5 		\
		mongodb-org-tools-4.2.5; yum clean all

RUN mkdir -p /data/db

RUN echo 'root:root' | chpasswd
RUN echo 'mongod:mongod' | chpasswd
RUN usermod -aG wheel mongod
RUN echo "mongod ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/mongod && \
		chmod 0440 /etc/sudoers.d/mongod

VOLUME  ["/data/db", "/var/lib/mongo", "/var/log/mongodb"] 


EXPOSE 27017
ENTRYPOINT ["/usr/bin/mongod", "--bind_ip_all"]
