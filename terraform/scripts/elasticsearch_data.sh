#!/bin/bash

# Update system and install necessary tools
sudo apt update
sudo apt install -y openjdk-17-jdk wget

# Download and extract Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.10.2-linux-x86_64.tar.gz
tar -xzf elasticsearch-8.10.2-linux-x86_64.tar.gz
sudo mv elasticsearch-8.10.2 /usr/share/elasticsearch

# Create Elasticsearch data and logs directories
sudo mkdir -p /usr/share/elasticsearch/data
sudo mkdir -p /usr/share/elasticsearch/logs
sudo chown -R $USER:$USER /usr/share/elasticsearch

# Create Elasticsearch configuration
cat <<EOF > /usr/share/elasticsearch/config/elasticsearch.yml
cluster.name: fullscale-cluster
node.name: ${HOSTNAME}
node.roles: [data, ingest]
path.data: /usr/share/elasticsearch/data
path.logs: /usr/share/elasticsearch/logs
network.host: 0.0.0.0
discovery.seed_hosts: ["es-master1", "es-master2", "es-master3"]
EOF

# Configure JVM heap size
cat <<EOF > /usr/share/elasticsearch/config/jvm.options.d/heap.options
-Xms2g
-Xmx2g
EOF

# Start Elasticsearch as a background process
/usr/share/elasticsearch/bin/elasticsearch -d
