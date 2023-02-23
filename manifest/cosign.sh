#!/bin/bash
#install go 1.19
wget  https://go.dev/dl/go1.19.linux-amd64.tar.gz 
sudo tar -xvf go1.19.linux-amd64.tar.gz   
sudo mv go /usr/local 
export GOROOT=/usr/local/go 
export GOPATH=$HOME/Projects/Proj1 
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 
#install cosign
go install github.com/sigstore/cosign/cmd/cosign@latest
# Generate a key-pair with a password:
export COSIGN_PASSWORD='C0S!gN'
cosign generate-key-pair
