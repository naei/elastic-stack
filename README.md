## docker-elasticstack

The Elastic Stack: Elasticsearch, Logstash & Kibana

### Build
<pre><code>docker build -t naei/elasticstack .</code></pre>

### Run 
#### ...in shell
<pre><code>docker run -it \
  -p 9200:9200 \
  -p 9300:9300 \
  -p 5601:5601 \
  naei/elasticstack</code></pre>

#### ...in detached mode
<pre><code>docker run -dit \
  -p 9200:9200 \
  -p 9300:9300 \
  -p 5601:5601 \
  naei/elasticstack</code></pre>

#### ...and watch / parse / save logs with Logstash
<pre><code>docker run -dit \
-p 9200:9200 \
-p 9300:9300 \
-p 5601:5601 \
-v <i><b>/var/log</b></i>:/var/log \
-v <i><b>~/conf/logstash</b></i>:/etc/logstash \
naei/elasticstack</code></pre>

Notes: 
  - On this repository, the files in the conf/logstash directory are examples, and not necessarily needed.
  - Logstash conf files and volumes must be added / edited depending on the needs and the folders structure of each environment.

### Troubleshooting

#### On which IP the server is running?
<pre><code>docker inspect --format '{{ .NetworkSettings.IPAddress }}' <i><b>container_name_or_id</b></i> </code></pre>