Connaisseur is a Kubernetes admission controller to integrate container image signature verification and trust pinning into a cluster.


## 1. Install Connaisseur

```
git clone https://github.com/sse-secure-systems/connaisseur.git
cd connaisseur
helm install connaisseur helm --atomic --create-namespace --namespace connaisseur
```

This can take a few minutes. You should be prompted something like:

```
NAME: connaisseur
LAST DEPLOYED: Fri Jul  9 20:43:10 2021
NAMESPACE: connaisseur
STATUS: deployed
REVISION: 1
TEST SUITE: None
```


## 2. configure Connaisseur

Connaisseur is configured via helm/values.yaml, so we will start there. We need to set Connaisseur to use our previously created public key for validation. To do so, go to the `.validators` and find the `default` validator. We need to uncomment the trust root with name default and add our previously created public key. also the `type` needs to be set to `cosign`. 
The result should look similar to this:

>> screenshot

## Test Connaisseur

First test 



