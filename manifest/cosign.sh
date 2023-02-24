#!/bin/bash
#install go 1.19
#wget  https://go.dev/dl/go1.19.linux-amd64.tar.gz 
#sudo tar -xvf go1.19.linux-amd64.tar.gz   
#sudo mv go /usr/local 
#export GOROOT=/usr/local/go 
#export GOPATH=$HOME/Projects/Proj1 
#export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 
#install cosign
#go install github.com/sigstore/cosign/cmd/cosign@latest
wget "https://github.com/sigstore/cosign/releases/download/v1.6.0/cosign-linux-amd64"
mv cosign-linux-amd64 /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign
# Generate a key-pair with a password:
export COSIGN_PASSWORD='C0S!gN'
cosign generate-key-pair
