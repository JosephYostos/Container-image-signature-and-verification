#!/bin/bash
#install cosign
wget "https://github.com/sigstore/cosign/releases/download/v1.6.0/cosign-linux-amd64"
mv cosign-linux-amd64 /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign
# Generate a key-pair with a password:
export COSIGN_PASSWORD='C0S!gN'
cosign generate-key-pair
