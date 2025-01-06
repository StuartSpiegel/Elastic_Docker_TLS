FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

USER root

RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/share/elasticsearch/config/certs

ENV ES_PATH_CONF=/usr/share/elasticsearch/config
WORKDIR /usr/share/elasticsearch/config

RUN echo "Generating CA..." && \
    # Use a non-empty password for the CA
    echo "changeme" | elasticsearch-certutil ca --pem \
      --out /usr/share/elasticsearch/config/certs/elastic-stack-ca.zip \
      --pass "changeme" && \
    unzip /usr/share/elasticsearch/config/certs/elastic-stack-ca.zip \
      -d /usr/share/elasticsearch/config/certs && \
    echo "Generating Node Cert..." && \
    # Supply same passphrase so it can read the CA
    echo "changeme" | elasticsearch-certutil cert --pem \
      --name "es-node" \
      --dns "es-master1,es-master2,es-master3,es-data1,es-data2,es-data3" \
      --ip "127.0.0.1" \
      --ca-cert /usr/share/elasticsearch/config/certs/ca/ca.crt \
      --ca-key  /usr/share/elasticsearch/config/certs/ca/ca.key \
      --ca-pass "changeme" \
      --out /usr/share/elasticsearch/config/certs/elastic-certificates.zip \
      --pass "changeme" && \
    unzip /usr/share/elasticsearch/config/certs/elastic-certificates.zip \
      -d /usr/share/elasticsearch/config/certs/node

RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/certs && \
    chmod -R go-rwx /usr/share/elasticsearch/config/certs

COPY elasticsearch.yml /usr/share/elasticsearch/config/
ENV ELASTIC_PASSWORD="MyElasticsearchPassword"

USER elasticsearch
