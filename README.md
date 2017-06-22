# elastic-stack

Elastic Stack sample setup for Nginx with Filebeat using Docker.

## Server:  Elasticsearch, Logstash & Kibana

### Build
```
cd ./elastic-stack
docker build -t naei/elastic-stack .
```

### Run
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

#### Troubleshooting
In some cases, Elasticsearch might not start properly. In case of trouble, you can try the following commands **on the host** to fix it:
- Increase the number of memory map areas: `sysctl -w vm.max_map_count=262144`
- Delete all stopped containers (including data-only containers); `docker rm $(docker ps -aq)`

### Set up Kibana

- Connect with the default credentials: `elastic:changeme`.  
*It is strongly recommended to immediately change the password.*  

- On the first start, Kibana ask to configure an index pattern. Write the `filebeat-*` pattern then click on "Create".  

- Finally you can import the Nginx logs dashboard: "Management" > "Saved Objects" > "Import" > Import the dashboard from the local folder:`<path-to>/elastic-stack/conf/kibana/dashboards/nginx.json`  

## Client: Filebeat

### Build
```
cd ./elastic-beats
docker build -t naei/elastic-beats .
```

### Run
In `<path-to>/elastic-beats/conf/filebeat/filebeat.yml` edit `hosts` with the Elastic Stack server address.
Then run:  
```
docker run \
-v <path-to>/elastic-beats/conf/filebeat/filebeat.yml:/etc/filebeat/filebeat.yml \
-v /var/log/nginx:/var/log/nginx \
-d naei/elastic-beats
```

-----

## Bonus stage: basic security setup

What you need on your server: 
  - A Nginx installation (and to know how to use it).
  - The SSL certificates of your server.
  - To ensure that the ports 443, 9243 and 5044 are accessible from the web.
  - To ensure that the ports 9200, 9300 and 5601 are NOT accessible from the web.

### Secure Kibana & Elasticsearch

As we might need to access Kibana and Elasticsearch API from heterogeneous systems, we want to set up a basic auth to connect to these services.

If you don't have one yet, setup a .htpasswd file:
```
htpasswd -c /etc/nginx/.htpasswd your-user
```

This server block configuration will allow Kibana to be accessible via https://elastic.your-domain.com and Elasticsearch API to be accessible via https://elastic.your-domain.com:9243. Credentials will be needed in order to access these addresses.
(For the nodejs-cli example, your can 

```
server {
  listen 80;
  listen [::]:80;

  server_name elastic.your-domain.com;

  location / {
    return 301 https://$server_name$request_uri;
  }
}
server {
  listen 443;
  listen [::]:443;

  server_name elastic.your_domain;

  error_log  /var/log/nginx/kibana_error.log;
  access_log /var/log/nginx/kibana_access.log;

  ssl on;
  ssl_certificate     path/to/ssl/certificate/your-domain.crt;
  ssl_certificate_key path/to/ssl/private/key/your-domain.key;

  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;

  location / {
    proxy_pass http://localhost:5601;
  }
}
server {
  listen 9243;
  listen [::]:9243;

  server_name elastic.your_domain;

  error_log  /var/log/nginx/elasticsearch_error.log;
  access_log /var/log/nginx/elasticsearch_access.log;

  ssl on;
  ssl_certificate     path/to/ssl/certificate/your-domain.crt;
  ssl_certificate_key path/to/ssl/private/key/your-domain.key;

  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;

  location / {
    proxy_pass http://localhost:9200;
  }
}

```

Don't forget to restart/reload Nginx to take effect.

Note: from the nodejs-cli-example project, you will be able to connect to the Elasticsearch API as it:
```
const client = new elasticsearch.Client({
  host: 'https://your-user:your-password@your-domain.com:9243',
  log: 'trace'
});
```

### Secure Logstash / Filebeat communication

This will setup a secure connection between Logstash and Filebeat. Logstash will only accept to receive data sent to your-domain.com with recognized Filebeat clients owning the server certificate.

#### Logstash

On your Elastic Stack server, you can create SSL certificate/key pair and save them to the project folder:
```
mkdir <path-to>/elastic-stack/conf/ssl
cd <path-to>/elastic-stack/conf/ssl
openssl req -x509 -nodes -newkey rsa:2048 -days 365 -keyout elastic.key -out elastic.crt -subj /CN=your-domain.com
```
Backup elastic.crt, you will need it on your Filebeat client(s) too.

Edit the `input` part of `/elastic-stack/conf/logstash/conf.d/logstash.conf` to setup :
```
input {
  beats {
      port => 5044
      ssl => true
      ssl_certificate => "/etc/ssl/elastic.crt"
      ssl_key => "/etc/ssl/elastic.key"
  }
}
```

When running your naei/elastic-stack container, you will need to bind these files to the container by adding this line:
```
-v <path-to>/elastic-stack/conf/ssl:/etc/ssl \
```

#### Filebeat

On your Filebeat client(s):

- Copy the previously saved elastic.crt file into `<path-to>/elastic-beats/conf/ssl` (create the `ssl` folder).
- Edit the `output.logstash` in the `<path-to>/elastic-beats/conf/filebeat.yml` file in order add the server certificate:
```
output.logstash:

  hosts: ["your-domain.com:5044"]
  ssl:
    certificate_authorities: [ "/etc/ssl/elastic.crt" ]
```

When running your naei/elastic-beats container, you will need to bind the certificate to the container by adding this line:
```
-v <path-to>/elastic-beats/conf/ssl:/etc/ssl \
```

