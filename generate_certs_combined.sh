#!/usr/bin/env bash
#
# Generates Elasticsearch & Kibana certificates using elasticsearch-certutil (via Docker),
# ensuring absolute paths are used for volume mounts (required on macOS/Windows).
#
# Requirements:
#   - Docker installed locally
#   - Permission to run docker commands
#
# Usage:
#   ./generate_elastic_certs.sh \
#       --certs-dir ./certs \
#       --es-version 8.10.2 \
#       --node-dns "es-master1,es-master2,es-master3,es-data1,es-data2,es-data3" \
#       --kibana-dns "kibana1,kibana2" \
#       --ca-pass myCaPassword \
#       --p12-pass myNodePass
#
# For more info, run with --help

set -euo pipefail

# Default values
CERTS_DIR="./certs"
ES_VERSION="8.10.2"
NODE_DNS="elastic"
KIBANA_DNS="kibana"
CA_PASS="changeme"
P12_PASS="changeme"
DOCKER_IMG_BASE="docker.elastic.co/elasticsearch/elasticsearch"

function usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --certs-dir PATH      Directory to store generated certs (default: ./certs)
  --es-version VERSION  Elasticsearch version for Docker image (default: 8.10.2)
  --node-dns CSV       Comma-separated list of DNS names for Elasticsearch nodes
  --kibana-dns CSV     Comma-separated list of DNS names for Kibana
  --ca-pass PASSWORD    Password for the CA keystore (default: blank)
  --p12-pass PASSWORD   Password for the PKCS#12 node certificates (default: blank)
  --help                Show this help message

Examples:
  $0 --certs-dir ./certs --node-dns "es-master1,es-master2" --ca-pass MyCAPass --p12-pass MyNodePass
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --certs-dir)
      CERTS_DIR="$2"
      shift 2
      ;;
    --es-version)
      ES_VERSION="$2"
      shift 2
      ;;
    --node-dns)
      NODE_DNS="$2"
      shift 2
      ;;
    --kibana-dns)
      KIBANA_DNS="$2"
      shift 2
      ;;
    --ca-pass)
      CA_PASS="$2"
      shift 2
      ;;
    --p12-pass)
      P12_PASS="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$NODE_DNS" ]]; then
  echo "Error: --node-dns is required. Provide at least one DNS name for ES nodes."
  exit 1
fi

echo "================================================="
echo "Generating Elasticsearch & Kibana Certificates..."
echo "================================================="
echo "CERTS_DIR:    $CERTS_DIR"
echo "ES_VERSION:   $ES_VERSION"
echo "NODE_DNS:     $NODE_DNS"
echo "KIBANA_DNS:   $KIBANA_DNS"
echo "CA_PASS:      ${CA_PASS:+"<set>"}"
echo "P12_PASS:     ${P12_PASS:+"<set>"}"
echo ""

mkdir -p "$CERTS_DIR"
CERTS_DIR_ABS="$(cd "$CERTS_DIR" && pwd)"
echo "Using absolute path for certs: $CERTS_DIR_ABS"

# 1. Generate CA if it doesn't exist
CA_FILE="$CERTS_DIR_ABS/elastic-stack-ca.p12"
if [[ ! -f "$CA_FILE" ]]; then
  echo "[Step 1/4] Generating Certificate Authority (CA)..."
  docker run --rm -v "$CERTS_DIR_ABS:/certs" "${DOCKER_IMG_BASE}:${ES_VERSION}" bash -c "echo '' | elasticsearch-certutil ca --out /certs/elastic-stack-ca.p12 --pass \"${CA_PASS}\""
  echo "CA generated at $CA_FILE"
else
  echo "CA file already exists at $CA_FILE. Skipping CA generation."
fi

# 2. Generate ES node certificate
ES_NODE_P12="$CERTS_DIR_ABS/elasticsearch-nodes.p12"
if [[ ! -f "$ES_NODE_P12" ]]; then
  echo "[Step 2/4] Generating Elasticsearch node certificate..."
  docker run --rm -v "$CERTS_DIR_ABS:/certs" "${DOCKER_IMG_BASE}:${ES_VERSION}" bash -c "echo '' | elasticsearch-certutil cert --ca /certs/elastic-stack-ca.p12 --ca-pass \"${CA_PASS}\" --out /certs/elasticsearch-nodes.p12 --pass \"${P12_PASS}\" --dns ${NODE_DNS}"
  echo "Elasticsearch node certificate generated at $ES_NODE_P12"
else
  echo "Elasticsearch node certificate already exists at $ES_NODE_P12. Skipping."
fi

# 3. Generate Kibana certificate if requested
if [[ -n "$KIBANA_DNS" ]]; then
  KIBANA_P12="$CERTS_DIR_ABS/kibana-nodes.p12"
  if [[ ! -f "$KIBANA_P12" ]]; then
    echo "[Step 3/4] Generating Kibana node certificate..."
    docker run --rm -v "$CERTS_DIR_ABS:/certs" "${DOCKER_IMG_BASE}:${ES_VERSION}" bash -c "echo '' | elasticsearch-certutil cert --ca /certs/elastic-stack-ca.p12 --ca-pass \"${CA_PASS}\" --out /certs/kibana-nodes.p12 --pass \"${P12_PASS}\" --dns ${KIBANA_DNS}"
    echo "Kibana node certificate generated at $KIBANA_P12"
  else
    echo "Kibana node certificate already exists at $KIBANA_P12. Skipping."
  fi
  
  # 4. Convert Kibana PKCS#12 to PEM for Kibana usage
  if [[ -f "$KIBANA_P12" ]]; then
    echo "[Step 4/4] Converting Kibana PKCS#12 to PEM"
    docker run --rm -v "$CERTS_DIR_ABS:/certs" "${DOCKER_IMG_BASE}:${ES_VERSION}" bash -c "openssl pkcs12 -in /certs/kibana-nodes.p12 -nocerts -nodes -out /certs/kibana.key -password pass:${P12_PASS} && openssl pkcs12 -in /certs/kibana-nodes.p12 -clcerts -nokeys -out /certs/kibana.crt -password pass:${P12_PASS}"
    echo "Kibana certificate and key generated at:"
    echo "  - /certs/kibana.crt"
    echo "  - /certs/kibana.key"
  fi
else
  echo "[Step 3/4] Kibana DNS not provided. Skipping Kibana certificate generation."
fi

echo "================================================="
echo "Certificate Generation Complete."
echo "CA:            $CA_FILE"
echo "ES Node Cert:  $ES_NODE_P12"
[[ -n "$KIBANA_DNS" ]] && echo "Kibana Cert PKCS#12:    $KIBANA_P12"
echo "================================================="
