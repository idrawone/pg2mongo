FROM centos:centos7
MAINTAINER iDrawone <idrawone@gmail.com>

RUN yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release yum-utils net-tools which; yum clean all
