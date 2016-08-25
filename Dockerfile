FROM ubuntu:16.04
MAINTAINER Lucas Pantanella

# Skip "apt-get install" interactive prompts during build
ARG DEBIAN_FRONTEND=noninteractive

RUN \
# Base install
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y wget curl vim nano apt-utils apt-transport-https openjdk-8-jdk && \
# Add the Elastic key & repositories
  wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  apt-key adv --recv-keys --keyserver keyserver.ubuntu.com D88E42B4 && \
  echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list && \
  echo "deb https://packages.elastic.co/kibana/4.5/debian stable main" >> /etc/apt/sources.list && \
  echo "deb https://packages.elastic.co/logstash/2.3/debian stable main" >> /etc/apt/sources.list && \
# Install the Elasticstack
  apt-get update && apt-get install -y elasticsearch kibana logstash && \
  #sed -i '/elasticsearch.url:/s/^# //g' /opt/kibana/config/kibana.yml && \
  /opt/kibana/bin/kibana plugin --install elastic/sense

EXPOSE \
  # Elasticsearch RESTful API / Java API
  9200 9300 \
  # Kibana
  5601

ENTRYPOINT \
  service elasticsearch start && \
  service kibana start && \
  /bin/bash