# Extends rocker/shiny-verse with oracle instant client:
# 1. oracle instant client with oci
# 2. rocker/shiny-verse

ARG   OIC_VERSION=18.5
ARG   R_VERSION=3.5.3

# Oracle Instant Client (oci) ########################################################################
#
# https://github.com/oracle/docker-images/blob/master/OracleInstantClient/dockerfiles/18.3.0/Dockerfile
#
# LICENSE UPL 1.0
#
# Copyright (c) 2014-2018 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
#
# Dockerfile template for Oracle Instant Client
#
# HOW TO BUILD THIS IMAGE
# -----------------------
#
# Run:
#      $ docker build -t oracle/instantclient:18.3.0 .
#
#
FROM oraclelinux:7-slim as oracle-instant-client

ARG  OIC_VERSION
ENV  R_VERSION=${R_VERSION}

RUN  curl -o /etc/yum.repos.d/public-yum-ol7.repo https://yum.oracle.com/public-yum-ol7.repo && \
     yum-config-manager --enable ol7_oracle_instantclient && \
     yum -y install oracle-instantclient$OIC_VERSION-basic oracle-instantclient$OIC_VERSION-devel oracle-instantclient$OIC_VERSION-sqlplus && \
     rm -rf /var/cache/yum



# Golang ############################################################################################
FROM rocker/shiny-verse:${R_VERSION} as rlang

ARG  OIC_VERSION
ARG  R_VERSION

ENV  OIC_VERSION=${OIC_VERSION}
ENV  R_VERSION=${R_VERSION}


COPY --from=oracle-instant-client  /usr/lib/oracle /usr/lib/oracle
COPY --from=oracle-instant-client  /usr/share/oracle /usr/share/oracle
COPY --from=oracle-instant-client  /usr/include/oracle /usr/include/oracle
COPY ./oci8.pc /usr/lib/pkgconfig/oci8.pc


RUN  sed -i 's/OIC_VERSION/'"$OIC_VERSION"'/' /usr/lib/pkgconfig/oci8.pc && \
     apt update && apt install \
     libaio1

ENV  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/$OIC_VERSION/client64/lib:/usr/include/oracle/$OIC_VERSION/client64/
ENV  OCI_LIB=/usr/lib/oracle/$OIC_VERSION/client64/lib
ENV  OCI_INC=/usr/include/oracle/$OIC_VERSION/client64

RUN  ln -s /lib64 /usr/lib64 && \
     echo /usr/lib/oracle/$OIC_VERSION/client64/lib > /etc/ld.so.conf.d/oracle-instantclient$OIC_VERSION.conf && \
     ldconfig && \
     R -e "install.packages('ROracle')"

ENV PATH=$PATH:/usr/lib/oracle/$OIC_VERSION/client64/bin
