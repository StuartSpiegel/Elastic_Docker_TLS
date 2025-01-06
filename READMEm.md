# Docker Configuration for 6 Node Elasticsearch cluster with TLS Wildcard cert

### How This Dockerfile Works
- Starts from the official Elasticsearch 8.6.2 image.
- Generates a CA and node certificates (in a simplistic way) for all possible Elasticsearch containers (master & data) in the cluster.
- Uses a single wildcard certificate for demonstration (DNS names: es-master1, es-master2, es-master3, es-data1, es-data2, es-data3).
- In production, you would generate unique certs for each node or use FQDN.
- Copies a base elasticsearch.yml into the image.
- Sets a default ELASTIC_PASSWORD environment variable for the built-in elastic user (again, not recommended to embed secrets in the image for production).

~~~
# ------------------------------------------------------------------
# Base Elasticsearch config loaded by all nodes.
# Additional node-specific settings (like node.roles, node.name) will
# be overridden via environment variables in docker-compose.yml
# ------------------------------------------------------------------

cluster.name: "my-secure-tls-cluster"

# Enable Security
xpack.security.enabled: true

# Enable TLS for HTTP (REST) layer
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/node/instance.p12
xpack.security.http.ssl.truststore.path: certs/node/instance.p12

# OR if using PEM:
# xpack.security.http.ssl.enabled: true
# xpack.security.http.ssl.certificate: certs/node/es-node.crt
# xpack.security.http.ssl.key: certs/node/es-node.key
# xpack.security.http.ssl.certificate_authorities: [ "certs/ca/ca.crt" ]

# Enable TLS for Transport layer (inter-node communication)
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/node/instance.p12
xpack.security.transport.ssl.truststore.path: certs/node/instance.p12

# OR if using PEM:
# xpack.security.transport.ssl.enabled: true
# xpack.security.transport.ssl.verification_mode: certificate
# xpack.security.transport.ssl.certificate: certs/node/es-node.crt
# xpack.security.transport.ssl.key: certs/node/es-node.key
# xpack.security.transport.ssl.certificate_authorities: [ "certs/ca/ca.crt" ]

# Uncomment or add any other settings you wish to customize.
# For example, to allow using the 'elastic' user from the host:
# xpack.security.http.ssl.client_authentication: optional
~~~

# Docker Compose

~~~
version: "3.8"

services:
  ###################################################################
  # 3 Master-eligible Nodes
  ###################################################################
  es-master1:
    image: my-elasticsearch:latest
    container_name: es-master1
    environment:
      - node.name=es-master1
      - node.roles=master
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      # Java heap (example: 1GB). Adjust for your hardware.
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-master1-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"   # Expose only on master1 for easy testing
    networks:
      - esnet

  es-master2:
    image: my-elasticsearch:latest
    container_name: es-master2
    environment:
      - node.name=es-master2
      - node.roles=master
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-master2-data:/usr/share/elasticsearch/data
    networks:
      - esnet

  es-master3:
    image: my-elasticsearch:latest
    container_name: es-master3
    environment:
      - node.name=es-master3
      - node.roles=master
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-master3-data:/usr/share/elasticsearch/data
    networks:
      - esnet

  ###################################################################
  # 3 Data + Ingest + Coordinating Nodes
  ###################################################################
  es-data1:
    image: my-elasticsearch:latest
    container_name: es-data1
    environment:
      - node.name=es-data1
      - node.roles=data,ingest,transform,ml,remote_cluster_client
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-data1-data:/usr/share/elasticsearch/data
    networks:
      - esnet

  es-data2:
    image: my-elasticsearch:latest
    container_name: es-data2
    environment:
      - node.name=es-data2
      - node.roles=data,ingest,transform,ml,remote_cluster_client
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-data2-data:/usr/share/elasticsearch/data
    networks:
      - esnet

  es-data3:
    image: my-elasticsearch:latest
    container_name: es-data3
    environment:
      - node.name=es-data3
      - node.roles=data,ingest,transform,ml,remote_cluster_client
      - discovery.seed_hosts=es-master1,es-master2,es-master3,es-data1,es-data2,es-data3
      - cluster.initial_master_nodes=es-master1,es-master2,es-master3
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-data3-data:/usr/share/elasticsearch/data
    networks:
      - esnet

volumes:
  es-master1-data:
  es-master2-data:
  es-master3-data:
  es-data1-data:
  es-data2-data:
  es-data3-data:

networks:
  esnet:
    driver: bridge
~~~

# Key Points in docker-compose.yml

**image: my-elasticsearch:latest**

- Assumes you built your Dockerfile with

~~~
 docker build -t my-elasticsearch .
~~~

- node.roles:
- master for the 3 master-eligible nodes. data,ingest,transform,ml,remote_cluster_client for the data nodes. (Feel free to adjust as needed, e.g. if you just want data,ingest coordinating_only=false, etc.)
- discovery.seed_hosts / cluster.initial_master_nodes:
Ensures all 6 containers discover each other and form a single cluster.

- ports: Only 9200 is published on es-master1. You could also expose ports on other nodes for debugging, or keep them internal.

# Build and Run

~~~
docker build -t my-elasticsearch .

docker-compose up -d

# Make sure each service is in a healthy/running state.
docker-compose ps
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