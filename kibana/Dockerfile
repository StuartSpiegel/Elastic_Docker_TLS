FROM docker.elastic.co/kibana/kibana:8.10.2
COPY --chown=kibana:kibana config/kibana.yml /usr/share/kibana/config/kibana.yml

# Expose port if desired (often controlled via docker-compose)
# EXPOSE 5601

# By default, Kibana runs as "USER kibana"
# CMD ["kibana"] is inherited from the base image
