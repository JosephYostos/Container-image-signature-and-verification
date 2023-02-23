#!/bin/bash

#install helm
snap install helm --classic
# Add the Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/
# Scan your Helm repositories to fetch the latest available charts.
helm repo update
# Install the Kyverno Helm chart into a new namespace called "kyverno"
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
# create policy 


