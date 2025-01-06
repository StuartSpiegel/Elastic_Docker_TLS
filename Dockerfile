# Use the official Elasticsearch 8.x image
FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

###############################################################################
# 1) Generate Self-Signed Certificates using elasticsearch-certutil
###############################################################################
USER root

# Create directories to store certs
RUN mkdir -p /usr/share/elasticsearch/config/certs
WORKDIR /usr/share/elasticsearch/config

# -- Batch mode: The "yes" flag will auto-generate certificates without prompts.
# -- We generate a CA, then node certificates using that CA.
# -- This example uses PKCS#12 keystores. You can also generate PEM if desired.
RUN echo "Generating CA..." && \
    yes '' | elasticsearch-certutil ca --silent --pem --out certs/elastic-stack-ca.zip && \
    unzip certs/elastic-stack-ca.zip -d certs/ca

# Generate a certificate/keystore for all nodes (wildcard DNS/IP).
# In a real environment, you would generate distinct certificates for each node
RUN echo "Generating wildcard certificate..." && \
    yes '' | elasticsearch-certutil cert --silent \
        --name "es-node" \
        --dns "es-master1,es-master2,es-master3,es-data1,es-data2,es-data3" \
        --ip "127.0.0.1" \
        --ca-cert certs/ca/ca.crt \
        --ca-key certs/ca/ca.key \
        --out certs/elastic-certificates.zip --pem && \
    unzip certs/elastic-certificates.zip -d certs/node

# Set file permissions so that elasticsearch user can read them
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/certs && \
    chmod -R go-rwx /usr/share/elasticsearch/config/certs

###############################################################################
# 2) Copy over a default elasticsearch.yml and set password
###############################################################################
COPY elasticsearch.yml /usr/share/elasticsearch/config/

# Example: Setting a default Elastic superuser password in the image
# WARNING: Hardcoding credentials in an image is not recommended for production!
ENV ELASTIC_PASSWORD="MyElasticsearchPassword"

USER elasticsearch
