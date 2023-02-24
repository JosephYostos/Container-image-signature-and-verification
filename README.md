# Container images signature and verification

This repo aims to set up a solution to sign container images and integrate it with Kubernetes clusters to improve the software supply chain security. 

## Learning Objectives.
1- Sign and publish a container image to an OCI registry
2- Demonstrate how the signature verification is performed in the cluster
3- Block unsigned images in a specific namespace, allow but warn on other namespaces
4- Notify of blocked or noncompliant images in Sysdig events UI

# Steps:

## Prepare the environment  

1- clone the github repo
```
git clone 
```

2- create a Kubernetes cluster.

To start our POC we need a kuberenetes clysetr to work with. I have created a 1 node kubeadm cluster on ubuntu 18.04 ec2 (t2.xlarge) instance. use the following script to install kubeadm (k8 2.25) with calico CNI (3.24):

```bash
./manifest/one-node-kubeadm.sh
```

## Cosign

1- Install cosign 
This script will install Cosign and generate a key with password `C0S!gN`. To change the password, edit the COSIGN_PASSWORD in the shell script.

```bash
source ./manifest/cosign.sh
```
Note: Make sure to run the script using source command to successfully add the `COSIGN_PASSWORD` variable to the env.

2- Login to your container registry using your own credentials. 
In this example, I used docker hub, so I will use the `docker login` command. 

```bash
docker login
```

3- upload the image to your registry.
For the demo purpose, I will download two different images, tag them, and then push them to my registry. Feel free to create or choose any other image.   

```bash 
docker pull alpine
docker pull hello-world
docker tag alpine josephyostos/dev-repo:signed 
docker tag hello-world josephyostos/dev-repo:unsigned
docker push josephyostos/dev-repo:signed
docker push josephyostos/dev-repo:unsigned
```

4- sign the image 

```bash
cosign sign --key cosign.key josephyostos/dev-repo:signed
```
When successfully signed, we should get message `Pushing signature to: index.docker.io/josephyostos/dev-repo`


## kyverno

1- install Kyverno 

Run the following script to install and configure Kyverno. This script will do the following:
- Install helm 
- Add Kyverno Helm repository
- Install the Kyverno Helm chart into a new namespace called "kyverno"
- Create secret has the cosign public key into "kyverno" namespace
- Create a policy to audit unsigned image deployments in all namespace and block unsigned images in namespace "enforce-namespace" 

```bash
./kyverno.sh
```

2- verify images in kubernetes

- Try to deploy unsigned image in default name space 

```bash
kubectl run unsignedimage --image=josephyostos/dev-repo:unsigned
```

you should be able to run a container using unsigned image, but if you check kyverno logs you should see an alert. run the following command to chekc the logs

```bash 
kubectl -n kyverno logs $(kubectl -n kyverno get po -l app.kubernetes.io/component=kyverno -ojsonpath='{.items[0].metadata.name}') |tail -n 3
```

you should see msg similar to this

```
E0224 00:34:09.288240       1 imageVerify.go:384] EngineVerifyImages "msg"="failed to verify image" "error"=".attestors[0].entries[0].keys: no matching signatures:\n" "kind"="Pod" "name"="unsignedimage" "namespace"="default" "policy"="verify-image"
```

- Try to deploy unsigned image in `enforce-namespace` namespace 

```bash
kubectl run unsignedimage -n enforce-namespace --image=josephyostos/dev-repo:unsigned
```

This time kyverno will deny the request, and you will get a masseage similar to this 

```
Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request:

policy Pod/enforce-namespace/unsignedimage for resource violation:

verify-image:
  verify-image: |
    failed to verify image docker.io/josephyostos/dev-repo:unsigned: .attestors[0].entries[0].keys: no matching signatures:
 ```

- Try to deploy signed image in `enforce-namespace` namespace 

```bash
kubectl run unsignedimage -n enforce-namespace --image=josephyostos/dev-repo:signed
```

This should be a successfull request.


3- uninstall kyverno

```bash
helm uninstall kyverno -n kyverno
```

## Connaisseur

1- Install Connaisseur
- This script will install Connaisseur and update the charts to allow only images from my registry and also it has to be signed using the cosign.pub

```bash
./scripts/connaisseur.sh
```

2- verify images in kubernetes

- Try to deploy a container once from a sgined image and another from unsigned image

```bash
kubectl run signedimage --image=josephyostos/dev-repo:signed
kubectl run unsignedimage --image=josephyostos/dev-repo:unsigned
```

The signed image should be deployied successfully while the unsigned one will be blocked. 

3- Uninstall Connaisseur

```bash
helm uninstall Connaisseur -n Connaisseur
```



## Modules

- [Module 0: Solution overview ](modules/solution-overview.md)
- [Module 1: Sign and publish a container image to an OCI registryusing Cosign ](modules/Sign-images.md)
- [Module 2: Signature verification via Kubernetes Admission controllers and Connaisseur](modules/Connaisseur.md)


