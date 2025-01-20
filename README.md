# Docker Configuration for 6 Node Elasticsearch cluster with TLS Wildcard cert and 2 Kibana Nodes

### How This Dockerfile Works
- Starts from the official Elasticsearch 8.10.2 image.
- Generates a CA and node certificates (in a simplistic way) for all possible Elastic stack containers (master & data & kibana) in the cluster.
- Uses a single wildcard certificate for demonstration (DNS names: es-master1, es-master2, es-master3, es-data1, es-data2, es-data3, kibana1, kibana2).
- In production, you would generate unique certs for each node or use FQDN.
- Copies a base elasticsearch.yml into the image.
- Sets a default ELASTIC_PASSWORD environment variable for the built-in elastic user (again, not recommended to embed secrets in the image for production).
- Generates Certs for Kibana using combined script (2 Kibana Nodes)

~~~
# =================================================================
# Elasticsearch Configuration for a Fullscale Cluster
# =================================================================

cluster.name: fullscale-cluster

# Example node configuration (override in docker-compose if needed):
node.name: es-master1

# Roles can be overridden via environment variables in docker-compose
# node.roles: [ "master" ]  # for a master node
# node.roles: [ "data", "ingest", "coordinating" ]  # for a data node

# Example path settings (Docker best practice is to use volumes)
path.data: /usr/share/elasticsearch/data
path.logs: /usr/share/elasticsearch/logs

# Network settings
network.host: 0.0.0.0
http.port: 9200
transport.port: 9300

# Discovery settings (often overridden in docker-compose)
discovery.seed_hosts: ["es-master1", "es-master2", "es-master3", "es-data1", "es-data2", "es-data3"]

# Security (TLS, etc.) can be configured by environment variables in docker-compose
# For example:
# xpack.security.enabled: true
# xpack.security.transport.ssl.enabled: true
# xpack.security.http.ssl.enabled: true

# Additional cluster-wide settings
cluster.initial_master_nodes: ["es-master1", "es-master2", "es-master3"]

# (Optional) Set a custom minimum master nodes for fault tolerance, but in 7.x+,
# we mostly rely on cluster.initial_master_nodes for bootstrapping.

# (Optional) Example usage of the built-in security realm
# xpack.security.authc.realms.native.native1.order: 0

~~~

# Docker Compose

~~~
version: '3.7'

services:
  # =======================
  # Elasticsearch Masters
  # =======================
  es-master1:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-master1
    environment:
      - node.name=es-master1
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=master
      - network.host=0.0.0.0

      # Enable security
      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms1g -Xmx1g

    ports:
      - 9201:9200
    volumes:
      - es-master1-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  es-master2:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-master2
    environment:
      - node.name=es-master2
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=master
      - network.host=0.0.0.0

      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms1g -Xmx1g

    ports:
      - 9202:9200
    volumes:
      - es-master2-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  es-master3:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-master3
    environment:
      - node.name=es-master3
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=master
      - network.host=0.0.0.0

      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms1g -Xmx1g

    ports:
      - 9203:9200
    volumes:
      - es-master3-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  # =======================
  # Elasticsearch Data/Ingest/Coordinating
  # =======================
  es-data1:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-data1
    environment:
      - node.name=es-data1
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=data,ingest
      - network.host=0.0.0.0

      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms2g -Xmx2g

    ports:
      - 9204:9200
    volumes:
      - es-data1-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  es-data2:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-data2
    environment:
      - node.name=es-data2
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=data,ingest
      - network.host=0.0.0.0

      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms2g -Xmx2g

    ports:
      - 9205:9200
    volumes:
      - es-data2-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  es-data3:
    build:
      context: ./elasticsearch
      dockerfile: Dockerfile
    container_name: es-data3
    environment:
      - node.name=es-data3
      - cluster.name=fullscale-cluster
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - node.roles=data,ingest
      - network.host=0.0.0.0

      - xpack.security.enabled=true
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.verification_mode=certificate
      # Updated to match your actual filename:
      - xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12
      - xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elasticsearch-nodes.p12

      - xpack.security.transport.ssl.keystore.secure_password=changeme
      - xpack.security.transport.ssl.truststore.secure_password=changeme
      - xpack.security.http.ssl.keystore.secure_password=changeme
      - xpack.security.http.ssl.truststore.secure_password=changeme

      # AWS environment variables for S3 snapshot usage
      - AWS_ACCESS_KEY_ID=AKIA...
      - AWS_SECRET_ACCESS_KEY=someSecret
      - AWS_DEFAULT_REGION=us-east-1

      - ELASTIC_PASSWORD=changeme
      - ES_JAVA_OPTS=-Xms2g -Xmx2g

    ports:
      - 9206:9200
    volumes:
      - es-data3-data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs
    networks:
      - es-network

  # =======================
  # Kibana Nodes
  # =======================
  kibana1:
    build:
      context: ./kibana
      dockerfile: Dockerfile
    container_name: kibana1
    environment:
      - SERVER_NAME=kibana1
      - ELASTICSEARCH_HOSTS=["https://es-master1:9200","https://es-master2:9200","https://es-master3:9200"]
      # - ELASTICSEARCH_USERNAME=elastic
      - ELASTICSEARCH_PASSWORD=changeme
      - ELASTICSEARCH_SSL_VERIFICATIONMODE=certificate
      - ELASTICSEARCH_SERVICEACCOUNTTOKEN=AAEAAWVsYXN0aWMva2liYW5hL3Rva2VuX0NPZWNhcFFCbjJ0U0c4WkNXazVTOl91LVFtMzEyUTRxV2hGMEZIWjk2TXc
      - ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=["/usr/share/kibana/config/certs/elastic-stack-ca.crt"]

    ports:
      - 5601:5601
    networks:
      - es-network
    depends_on:
      - es-master1
      - es-master2
      - es-master3
      - es-data1
      - es-data2
      - es-data3
    volumes:
      - ./certs:/usr/share/kibana/config/certs

  kibana2:
    build:
      context: ./kibana
      dockerfile: Dockerfile
    container_name: kibana2
    environment:
      - SERVER_NAME=kibana2
      - ELASTICSEARCH_HOSTS=["https://es-master1:9200","https://es-master2:9200","https://es-master3:9200"]
      # - ELASTICSEARCH_USERNAME=elastic
      - ELASTICSEARCH_PASSWORD=changeme
      - ELASTICSEARCH_SSL_VERIFICATIONMODE=certificate
      - ELASTICSEARCH_SERVICEACCOUNTTOKEN=AAEAAWVsYXN0aWMva2liYW5hL3Rva2VuX0NPZWNhcFFCbjJ0U0c4WkNXazVTOl91LVFtMzEyUTRxV2hGMEZIWjk2TXc
      - ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=["/usr/share/kibana/config/certs/elastic-stack-ca.crt"]


    ports:
      - 5602:5601
    networks:
      - es-network
    depends_on:
      - es-master1
      - es-master2
      - es-master3
      - es-data1
      - es-data2
      - es-data3
    volumes:
      - ./certs:/usr/share/kibana/config/certs

networks:
  es-network:
    driver: bridge

volumes:
  es-master1-data:
  es-master2-data:
  es-master3-data:
  es-data1-data:
  es-data2-data:
  es-data3-data:

~~~

# Key Points in docker-compose.yml

**image: my-elasticsearch:latest**

- Assumes you built your Dockerfile with

~~~
 docker-compose build
~~~

# Build and Run

~~~
docker-compose build

docker-compose up -d

# Make sure each service is in a healthy/running state.
docker-compose ps

docker-compose logs es-master1
~~~

# Verify security
- The --insecure flag is needed because it’s a self-signed certificate. For production, you would import the CA (certs/ca/ca.crt) into your trusted store or use a certificate signed by a recognized CA.

~~~
curl --insecure -u elastic:MyElasticsearchPassword https://localhost:9200
~~~

# Resetting the Elastic Default Password if needed

~~~
docker exec -it es-master1 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
~~~

# Testing VS Production

- For testing purposes I have hard coded the Elastic password as an ENVironment variable in the Dockerfile. For Security reasons you would never do this in Production.

# Terraform Deployment 

- Initialize and deploy with Terraform 

~~~
terraform init

terraform plan

terraform apply
~~~