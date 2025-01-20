#!/bin/bash
sudo apt update
sudo apt install -y kibana

cat <<EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://es-master1:9200", "http://es-master2:9200", "http://es-master3:9200"]
EOF

sudo systemctl start kibana
