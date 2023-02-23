# Container images signature and verification

This repo aims to set up a solution to sign container images and integrate it with Kubernetes clusters to improve the software supply chain security. 

## Learning Objectives.
1- Sign and publish a container image to an OCI registry
2- Demonstrate how the signature verification is performed in the cluster
3- Block unsigned images in a specific namespace, allow but warn on other namespaces
4- Notify of blocked or noncompliant images in Sysdig events UI

## Steps:

1-  Create Kuberenetes cluster  

To start our POC we need a kuberenetes clysetr to work with. I have created a 1 node kubeadm cluster on ubuntu 18.04 ec2 (t2.xlarge) instance. use the following script to install kubeadm (k8 2.25) with calico CNI (3.24):

```bash
./manifest/one-node-kubeadm.sh
```

2- Install cosign 
This script will install go 1.19, then install cosign and generate a key with password `C0S!gN`. To change the password edit the COSIGN_PASSWORD in the shell script.

```bash
source ./manifest/cosign.sh
```

3- Login to your container registry using your own cerdientials. 
I this example I used docker hub so I will use `docker login` command  

```bash
docker login
```

4- upload image to your registry.
For the demo purpose, I will download two different images and will tag it, then push it to my registry. feel free to create or choose any other image.    

```bash 
docker pull alpine
docker pull hello-world
docker tag alpine josephyostos/dev-repo:signed 
docker tag hello-world josephyostos/dev-repo:unsigned
docker push josephyostos/dev-repo:signed
docker push josephyostos/dev-repo:unsigned
```

5- sign the image 

```bash
cosign sign --key cosign.key josephyostos/dev-repo:signed
```
we will get message `Pushing signature to: index.docker.io/josephyostos/dev-repo`

6- Kyverno 

# Add the Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/
# Scan your Helm repositories to fetch the latest available charts.
helm repo update
# Install the Kyverno Helm chart into a new namespace called "kyverno"
helm install kyverno kyverno/kyverno -n kyverno --create-namespace



## Modules

- [Module 0: Solution overview ](modules/solution-overview.md)
- [Module 1: Sign and publish a container image to an OCI registryusing Cosign ](modules/Sign-images.md)
- [Module 2: Signature verification via Kubernetes Admission controllers and Connaisseur](modules/Connaisseur.md)


