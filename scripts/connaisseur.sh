#!/bin/bash
#install connaisseur
git clone https://github.com/sse-secure-systems/connaisseur.git
cd connaisseur
helm upgrade --install connaisseur helm --atomic --create-namespace --namespace connaisseur --set "validators[0].name=default,validators[0].type=cosign,validators[0].trust_roots[0].name=default,validators[0].trust_roots[0].key=$(cat ../cosign.pub),policy[0].pattern="docker.io/josephyostos/dev-repo*",policy[0].validator=default"
