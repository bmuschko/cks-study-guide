#!/bin/bash

# Delete and recreate target directory
rm -rf certs
mkdir certs
cd certs

# Generate self-signed root CA cert
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 36500 -subj "/OU=automated-ascent/CN=cks-ca" -out ca.crt

# Generate self-signed cert for application
openssl genrsa -out image-validation-webhook.key 2048
openssl req -new -sha256 -key image-validation-webhook.key -subj "/CN=image-validation-webhook" -out image-validation-webhook.csr
cat << EOF > extfile.cnf
keyUsage = critical, digitalSignature, keyEncipherment
basicConstraints = critical, CA:FALSE
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = DNS:image-validation-webhook
EOF
openssl x509 -req -in image-validation-webhook.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out image-validation-webhook.crt -days 36500 -sha256 -extfile extfile.cnf

# Generate self-signed cert for API server
openssl genrsa -out api-server-client.key 2048
openssl req -new -sha256 -key api-server-client.key -subj "/CN=api-server" -out api-server-client.csr
openssl x509 -req -in api-server-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out api-server-client.crt -days 36500 -sha256