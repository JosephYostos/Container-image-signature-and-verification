# Container images signature and verification

This repo aims to set up a solution to sign container images and integrate it with Kubernetes clusters to improve the software supply chain security. 

## Learning Objectives.
1- Sign and publish a container image to an OCI registry
2- Demonstrate how the signature verification is performed in the cluster
3- Block unsigned images in a specific namespace, allow but warn on other namespaces
4- Notify of blocked or noncompliant images in Sysdig events UI


## Modules

- [Module 0: Solution overview ](modules/solution-overview.md)
- [Module 1: Sign and publish a container image to an OCI registryusing Cosign ](modules/Sign-images.md)
