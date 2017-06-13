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
docker run \
-p 5601:5601 -p 5044:5044 -p 9200:9200 -p 9300:9300 \
-v <path-to>/elastic-stack/conf/logstash/conf.d/logstash.conf:/etc/logstash/conf.d/logstash.conf \
-v <path-to>/elastic-stack/conf/logstash/patterns:/etc/logstash/patterns \
-v <path-to>/elastic-stack/conf/logstash/templates:/etc/logstash/templates \
-it naei/elastic-stack
```

At this point, the Kibana interface should be available at `http://<server>:5601`.

Install and run Filebeat on the client, then go back to Kibana:
- Write `filebeat-*-*` pattern > "Create"

Finally you can import the Nginx logs dashboard: 
- "Management" > "Saved Objects" > "Import" > Import the dashboard from the local folder:`<path-to>/ubuntu/elastic-stack/dashboard/nginx.json`


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
-it naei/elastic-beats
```
