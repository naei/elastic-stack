FROM ubuntu:16.04
MAINTAINER Lucas Pantanella

# Skip "apt-get install" interactive prompts during build
ARG DEBIAN_FRONTEND=noninteractive
# Disable setting kernel parameters
ARG ES_SKIP_SET_KERNEL_PARAMETERS=true

RUN \
# Base install
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y wget curl httpie vim nano screen apt-utils apt-transport-https openjdk-8-jdk && \
# Add the Elastic key & repositories
  wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-5.x.list && \
  apt-get update && \
# Install Elasticsearch
  apt-get install -y elasticsearch && \
# Install Kibana
  apt-get install -y kibana && \
# Install Logstash
  apt-get install -y logstash && \
# Allow network access to Elasticsearch from the host
  sed -i "s/#network.host:.*/network.host: 127.0.0.1/" /etc/elasticsearch/elasticsearch.yml && \
  sed -i "s/#server.host:.*/server.host: 0.0.0.0/" /etc/kibana/kibana.yml

EXPOSE \
  # Elasticsearch RESTful API / Java API
  9200 9300 \
  # Kibana
  5601 \
  # Logstash
  5044

CMD \
  chown -R elasticsearch:elasticsearch /var/lib/elasticsearch && \
  service elasticsearch start && \
  service kibana start && \
  nohup /usr/share/logstash/bin/logstash --path.settings=/etc/logstash -f /etc/logstash/conf.d/logstash.conf > /var/log/logstash/logstash_run.log 2>&1 & \
  /bin/bash
