# elastic-stack

Elastic Stack sample setup for Nginx with Filebeat using Docker.

### Server:  Elasticsearch, Logstash & Kibana

#### Build
```
cd ./elastic-stack
docker build -t naei/elastic-stack .
```

#### Run
```
sysctl -w vm.max_map_count=262144
```
```
docker run \
-p 5601:5601 -p 5044:5044 -p 9200:9200 -p 9300:9300 \
-v <path-to>/elastic-stack/conf/logstash/conf.d/logstash.conf:/etc/logstash/conf.d/logstash.conf \
-v <path-to>/elastic-stack/conf/logstash/patterns:/etc/logstash/patterns \
-v <path-to>/elastic-stack/conf/logstash/templates:/etc/logstash/templates \
-v <path-to-save-elastic-data>:/var/lib/elacticsearch \
-d naei/elastic-stack
```

At this point, the Kibana interface should be available at `http://<server>:5601`.

#### Set up Kibana

- Connect with the default credentials: `elastic:changeme`.  
*It is strongly recommended to immediately change the password.*  

- On the first start, Kibana ask to configure an index pattern. Write the `filebeat-*` pattern then click on "Create".  

- Finally you can import the Nginx logs dashboard: "Management" > "Saved Objects" > "Import" > Import the dashboard from the local folder:`<path-to>/elastic-stack/conf/kibana/dashboards/nginx.json`  


### Client: Filebeat

#### Build
```
cd ./elastic-beats
docker build -t naei/elastic-beats .
```

#### Run
In `<path-to>/elastic-beats/conf/filebeat/filebeat.yml` edit `hosts` with the Elastic Stack server address.
Then run:  
```
docker run \
-v <path-to>/elastic-beats/conf/filebeat/filebeat.yml:/etc/filebeat/filebeat.yml \
-v /var/log/nginx:/var/log/nginx \
-d naei/elastic-beats
```
