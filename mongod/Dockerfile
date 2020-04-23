FROM centos7-base
MAINTAINER iDrawone <idrawone@gmail.com>

COPY mongodb.repo /etc/yum.repos.d/

RUN yum -y install mongodb-org-4.2.5 mongodb-org-server-4.2.5 	\
		mongodb-org-shell-4.2.5 mongodb-org-mongos-4.2.5 		\
		mongodb-org-tools-4.2.5; yum clean all
RUN mkdir -p /data/db

RUN yum -y install postgresql12-contrib; yum clean all

RUN echo 'root:root' | chpasswd
RUN echo 'mongod:mongod' | chpasswd
RUN usermod -aG wheel mongod
RUN echo "mongod ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/mongod && \
		chmod 0440 /etc/sudoers.d/mongod
RUN echo "export PATH=/usr/pgsql-12/bin:$PATH" | tee -a /root/.bashrc

VOLUME  ["/data/db", "/var/lib/mongo", "/var/log/mongodb"]
EXPOSE 27017

ENTRYPOINT ["/usr/bin/mongod", "--bind_ip_all"]
