FROM ubuntu:16.04
MAINTAINER Lucas Pantanella

# Skip "apt-get install" interactive prompts during build
ARG DEBIAN_FRONTEND=noninteractive

RUN \
# Base install
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y wget curl httpie vim nano screen apt-utils apt-transport-https openjdk-8-jdk && \
# Add the Elastic key & repositories
  wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-5.x.list && \
  apt-get update && \
# Install Filebeat
  apt-get install -y filebeat

ENTRYPOINT \
  chown -R 0 /etc/filebeat && chmod -R go-w /etc/filebeat && \
  service filebeat start && \
  /bin/bash
