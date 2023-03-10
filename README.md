# Container images signature and verification

## Goal 
This repo aims to set up a POC to sign container images and incorporate the verification into Kubernetes clusters to improve the software supply chain security.

## Learning Objectives.
By the end of this POC you should be to: 
- Sign and publish a container image to an OCI registry
- Demonstrate how the signature verification is performed in the cluster
- Block unsigned images in a specific namespace, allow but warn on other namespaces
- Notify of blocked or non-compliant images in Sysdig events UI

## overview

#### What is image signing?
Image signing is the process of adding a digital signature to an image in an OCI registry. This signature will allow the user of a container image to verify the source and trust the container image.

#### How does the image signing process work?
You can achieve container image verification in three simple steps:
- Pushing the image to a registry.
- Signing the image in the registry.
- Verifying the signature with every pull request.

#### what tools are we going to use?
- Signature: the most common signature solutions are Cosign and Notary. A Notary service consists of Notary server, Notary signer, Notary client, MySQL database. And you also need to setup MTLS between Notary server and Notary signer. While with Cosign we simply install binary. So will use Cosign
- Verification: In this POC I will demonstrate two different options for verification, Kyverno and Connaisseur.    
  - The good thing about Kyverno is that it is designed for Kubernetes and is very easy to configure. But it doesn't include a simple way to alert and monitor. So you will probably need to rely on another solution, like policy-repoter for alerting and getting an overview of the policy results.  
  - Connaisseur is easy to configure and operates in two modes: block or only detection. The only drawback I found during testing is that the detection and prevention modes are configured globally, so I can't choose to block unsigned images in one namespace and notify in another.
- Alerting: Finally, we will forward Connaisseur alerts to Sysdig cloud over the REST API. 

# Steps:

## Prepare the environment  

1- clone the github repo
```
git clone https://github.com/JosephYostos/Container-image-signature-and-verification.git
```

2- create a Kubernetes cluster.

To start our POC we need a kuberenetes clysetr to work with. I have created a 1 node kubeadm cluster on ubuntu 18.04 ec2 (t2.xlarge) instance. use the following script to install kubeadm (k8 2.25) with calico CNI (3.24):

```bash
./scripts/one-node-kubeadm.sh
```

## Cosign

1- Install cosign 
This script will install Cosign and generate a key with password `C0S!gN`. To change the password, edit the COSIGN_PASSWORD in the shell script.

```bash
source ./scripts/cosign.sh
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
./scripts/kyverno.sh
```

2- verify images in kubernetes

- Try to deploy an unsigned image in `default` namespace. 

```bash
kubectl run unsignedimage --image=josephyostos/dev-repo:unsigned
```

You should be able to run a container using the unsigned image, but if you check kyverno logs, you should see an alert. Run the following command to check the logs

```bash 
kubectl -n kyverno logs $(kubectl -n kyverno get po -l app.kubernetes.io/component=kyverno -ojsonpath='{.items[0].metadata.name}') |tail -n 3
```

You will see msg similar to this

```
E0224 00:34:09.288240       1 imageVerify.go:384] EngineVerifyImages "msg"="failed to verify image" "error"=".attestors[0].entries[0].keys: no matching signatures:\n" "kind"="Pod" "name"="unsignedimage" "namespace"="default" "policy"="verify-image"
```

- Try to deploy an unsigned image in `enforce-namespace` namespace. 

```bash
kubectl run unsignedimage -n enforce-namespace --image=josephyostos/dev-repo:unsigned
```

This time kyverno will deny the request, and you will get a message similar to this 

```
Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request:

policy Pod/enforce-namespace/unsignedimage for resource violation:

verify-image:
  verify-image: |
    failed to verify image docker.io/josephyostos/dev-repo:unsigned: .attestors[0].entries[0].keys: no matching signatures:
 ```

- Try to deploy a signed image in `enforce-namespace` namespace 

```bash
kubectl run unsignedimage -n enforce-namespace --image=josephyostos/dev-repo:signed
```

This time it should be successfully deployed.

3- cleanup: uninstall kyverno
Before testing Connaisseur, make sure to uninstall Kyverno.

```bash
helm uninstall kyverno -n kyverno
```

## Connaisseur

1- Install Connaisseur
- This script will install Connaisseur and update the charts to allow only signed images from my docker hub registry.

```bash
./scripts/connaisseur.sh
```

2- verify images in kubernetes

- Try to deploy two containers, first from a signed image and the other from an unsigned image.

```bash
kubectl run signedimage --image=josephyostos/dev-repo:signed
kubectl run unsignedimage --image=josephyostos/dev-repo:unsigned
```

The signed image should be deployed successfully, while the unsigned one will be blocked. 

## Notifying non-compliant images in Sysdig

Connaisseur offers a notifications template system that allows integration with Sysdig.

1- Create a sysdig.json file template under $connaisseur/helm/alert_payload_templates: 

```
{
    "events": [
        {
            "timestamp": "2021-11-08T13:44:05+00:00",
            "rule": "Check image signature",
            "priority": "warning",
            "output": "The image signature verification failed for image {{imagename}}",
            "source": "Connaisseur AC",
            "tags": [
                "foo",
                "bar"
            ],
            "output_fields": {
                "field1": "value1",
                "field2": "value2"
            }
        }
    ],
    "labels": {
        "label1": "label1-value",
        "label2": "label2-value"
    }
}
```

2- Update charts with Sysdig cloud URL and API token.

You either update the values.yaml or use the following command after adding the correct URL and token.

```bash
helm upgrade --install connaisseur helm --atomic --create-namespace --namespace connaisseur \
 --set "validators[0].name=default,validators[0].type=cosign,validators[0].trust_roots[0].name=default,validators[0].trust_roots[0].key=$(cat ../cosign.pub),policy[0].pattern="docker.io/josephyostos/dev-repo*",policy[0].validator=default" \
 --set alerting.admit_request.templates[0].template=sysdig,alerting.admit_request.templates[0].receiver_url="https://app.us4.sysdig.com/api/v1/eventsDispatch/ingest",alerting.admit_request.templates[0].headers="Authorization: Bearer fdf2b81c-e1b2-429a-826c-2bc73422bb84" \
 --set alerting.reject_request.templates[0].template=sysdig,alerting.reject_request.templates[0].receiver_url="https://app.us4.sysdig.com/api/v1/eventsDispatch/ingest",alerting.reject_request.templates[0].headers="Authorization: Bearer fdf2b81c-e1b2-429a-826c-2bc73422bb84" 
```

(please note that the https://secure.sysdig.com part of the URL will change if you are not in the default US1 region)

3- Cleanup: Uninstall Connaisseur  

```bash
helm uninstall Connaisseur -n Connaisseur  
```

