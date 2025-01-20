#!/bin/bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.10.2-linux-x86_64.tar.gz
tar -xzf elasticsearch-8.10.2-linux-x86_64.tar.gz
mv elasticsearch-8.10.2 /usr/share/elasticsearch

cat <<EOF > /usr/share/elasticsearch/config/elasticsearch.yml
cluster.name: fullscale-cluster
node.name: ${HOSTNAME}
node.roles: [master]
network.host: 0.0.0.0
discovery.seed_hosts: ["es-master1", "es-master2", "es-master3"]
cluster.initial_master_nodes: ["es-master1", "es-master2", "es-master3"]
EOF

/usr/share/elasticsearch/bin/elasticsearch -d
