FROM docker.elastic.co/elasticsearch/elasticsearch:8.10.2

# (Optional) Install any plugins you need:
# RUN elasticsearch-plugin install analysis-icu
# RUN elasticsearch-plugin install repository-s3
# ...

# Copy configuration files with the correct ownership
COPY --chown=elasticsearch:elasticsearch config/elasticsearch.yml /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch config/log4j2.properties /usr/share/elasticsearch/config/

# Expose ports if desired (often controlled via docker-compose)
# EXPOSE 9200 9300

# Switch to root only if needed to install packages, then back to elasticsearch
USER root
# (optional plugin installs)
USER elasticsearch

# Add secure settings via build ARG or Docker secrets
# Example: passing an ARG
ARG ES_P12_PASS=changeme

RUN echo "$ES_P12_PASS" | bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password -xf && \
    echo "$ES_P12_PASS" | bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password -xf && \
    echo "$ES_P12_PASS" | bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password -xf && \
    echo "$ES_P12_PASS" | bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password -xf

# By default, the official image runs as "USER elasticsearch"
# No need to switch user. The base image already handles it.
# CMD ["elasticsearch"] is inherited from the base image
