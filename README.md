## docker-elasticstack

The Elastic Stack: Elasticsearch, Logstash & Kibana

### Build
<pre><code>docker build -t elasticstack .</code></pre>

### Run 
#### ...in shell
<pre><code>docker run -it \
  -p 9200:9200 \
  -p 9300:9300 \
  -p 5601:5601 \
  --name elastic_stack \
  elasticstack</code></pre>

#### ...in detached mode
<pre><code>docker run -dit \
  -p 9200:9200 \
  -p 9300:9300 \
  -p 5601:5601 \
  --name elastic_stack \
  elasticstack</code></pre>

### Troubleshooting

#### On which IP the server is running?
<pre><code>docker inspect --format '{{ .NetworkSettings.IPAddress }}' elastic_stack</code></pre>