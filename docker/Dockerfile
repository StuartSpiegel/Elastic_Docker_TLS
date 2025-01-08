FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

USER root

RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/share/elasticsearch/config/certs
RUN mkdir -p /usr/share/kibana/config/certs/node/es-node

ENV ES_PATH_CONF=/usr/share/elasticsearch/config
WORKDIR /usr/share/elasticsearch/config

# Generate Elasticsearch Certificates
RUN echo "Generating CA..." && \
    echo "changeme" | elasticsearch-certutil ca --pem \
      --out /usr/share/elasticsearch/config/certs/elastic-stack-ca.zip \
      --pass "changeme" && \
    unzip /usr/share/elasticsearch/config/certs/elastic-stack-ca.zip \
      -d /usr/share/elasticsearch/config/certs && \
    echo "Generating Node Cert..." && \
    echo "changeme" | elasticsearch-certutil cert --pem \
      --name "es-node" \
      --dns "es-master1,es-master2,es-master3,es-data1,es-data2,es-data3" \
      --ip "127.0.0.1" \
      --ca-cert /usr/share/elasticsearch/config/certs/ca/ca.crt \
      --ca-key /usr/share/elasticsearch/config/certs/ca/ca.key \
      --ca-pass "changeme" \
      --out /usr/share/elasticsearch/config/certs/elastic-certificates.zip \
      --pass "changeme" && \
    unzip /usr/share/elasticsearch/config/certs/elastic-certificates.zip \
      -d /usr/share/elasticsearch/config/certs/node

# Copy Elasticsearch Certificates to Kibana
RUN cp /usr/share/elasticsearch/config/certs/node/es-node/es-node.crt \
       /usr/share/kibana/config/certs/node/es-node/ && \
    cp /usr/share/elasticsearch/config/certs/node/es-node/es-node.key \
       /usr/share/kibana/config/certs/node/es-node/

# Adjust Permissions for Kibana Certificates
RUN groupadd -r kibana && useradd -r -g kibana kibana && \
    chmod 600 /usr/share/kibana/config/certs/node/es-node/es-node.key && \
    chmod 644 /usr/share/kibana/config/certs/node/es-node/es-node.crt && \
    chown -R kibana:kibana /usr/share/kibana/config/certs/node/es-node

# Shared Volume for Certificates
RUN mkdir -p /shared/certs && \
    cp -r /usr/share/elasticsearch/config/certs/ /shared/certs && \
    chmod -R 755 /shared/certs

COPY elasticsearch.yml /usr/share/elasticsearch/config/
ENV ELASTIC_PASSWORD="MyElasticsearchPassword"

USER elasticsearch
