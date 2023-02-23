# Container images signature and verification

This repo aims to set up a solution to sign container images and integrate it with Kubernetes clusters to improve the software supply chain security. 

## Learning Objectives.
1- Sign and publish a container image to an OCI registry
2- Demonstrate how the signature verification is performed in the cluster
3- Block unsigned images in a specific namespace, allow but warn on other namespaces
4- Notify of blocked or noncompliant images in Sysdig events UI

## Steps:

create 

To be able to demonstrate the PoC workflow, a k8s cluster is required. In this case, we leverage kind to have a quick k8s environment in a Fedora 35 x86_64laptop using a podman rootless backend. Also, the following snippet shows how to install some required tools, including cosign, helm, etc.:

I have created a 1 node kubeadm cluster on ubuntu ec2 instance. use the following script to install kubeadm (k8 2.25) with calico CNI (3.24):

```bash
./manifest/one-node-kubeadm.sh
```

## Modules

- [Module 0: Solution overview ](modules/solution-overview.md)
- [Module 1: Sign and publish a container image to an OCI registryusing Cosign ](modules/Sign-images.md)
- [Module 2: Signature verification via Kubernetes Admission controllers and Connaisseur](modules/Connaisseur.md)


