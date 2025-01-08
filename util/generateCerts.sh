#!/bin/bash

# Variables
CERTS_DIR="./certs"
CA_ZIP="$CERTS_DIR/ca.zip"
CERTS_ZIP="$CERTS_DIR/certs.zip"
INSTANCES_FILE="./instances.yml"
ES_IMAGE="docker.elastic.co/elasticsearch/elasticsearch:8.10.2"

# Step 1: Create directories
echo "Creating certificates directory..."
mkdir -p "$CERTS_DIR"

# Step 2: Cleanup any existing files
if [ -f "$CA_ZIP" ]; then
    echo "Removing old CA archive..."
    rm -f "$CA_ZIP"
fi

if [ -f "$CERTS_ZIP" ]; then
    echo "Removing old certificates archive..."
    rm -f "$CERTS_ZIP"
fi

# Step 3: Generate CA certificate
echo "Generating CA certificate..."
docker run --rm -v "$(pwd):/certs" -u 0 $ES_IMAGE \
    elasticsearch-certutil ca --pem --out /certs/ca.zip

if [ ! -f "$CA_ZIP" ]; then
    echo "Error: CA certificate generation failed."
    exit 1
fi

echo "Unzipping CA certificate..."
unzip -o "$CA_ZIP" -d "$CERTS_DIR"

# Step 4: Generate node certificates
echo "Generating node certificates from $INSTANCES_FILE..."
docker run --rm -v "$(pwd):/certs" -v "$(pwd)/instances.yml:/instances.yml" -u 0 $ES_IMAGE \
    elasticsearch-certutil cert --ca-cert /certs/ca/ca.crt --ca-key /certs/ca/ca.key \
    --pem --in /instances.yml --out /certs/certs.zip

if [ ! -f "$CERTS_ZIP" ]; then
    echo "Error: Node certificate generation failed."
    exit 1
fi

echo "Unzipping node certificates..."
unzip -o "$CERTS_ZIP" -d "$CERTS_DIR"

# Step 5: Organize the certificates
echo "Organizing certificates..."
for node in es-master1 es-master2 es-master3 es-data1 es-data2 es-coord1 kibana1 kibana2; do
    mkdir -p "$CERTS_DIR/$node"
    if [ -f "$CERTS_DIR/$node.crt" ]; then
        mv "$CERTS_DIR/$node.crt" "$CERTS_DIR/$node/$node.crt"
    fi
    if [ -f "$CERTS_DIR/$node.key" ]; then
        mv "$CERTS_DIR/$node.key" "$CERTS_DIR/$node/$node.key"
    fi
done

echo "Certificates successfully generated and organized in the '$CERTS_DIR' directory."
