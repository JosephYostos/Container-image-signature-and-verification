## What is image signing?

Image signing is the process of adding a digital signature to an image in an OCI registry. This signature will allow the user of a container image to verify the source and trust the container image.

## How does the image signing process work?
There are several ways to sign container images, the simplest and the most common is using private/public key pairs. The private key is used to sign the image, and the public key is used to verify the signature.

## Cosign vs Notary

- Ease of use: Notary requires you to self-host a Notary service, while Cosign is a binary. You can install it using any package manager. It also means you can integrate Cosign it in any CI/CD solution. 
- Coverage/scope:  Notary only can be used to sign container images, not OCI artifacts. 
- Setup Complexity: A Notary service consists of Notary server, Notary signer, Notary client, MySQL database. And you also need to setup MTLS between Notary server and Notary signer. While with Cosign we simply install binary. 

That's why we will use cosign for our setup.

## Prepare your environment/requirements

- Cosign doesn't sign local images, you will need access to a container registry for cosign to work with. In this example, I used docker hub registry.
- You must have a write permission on the container registry to add the digital signature to images.

## Install Cosign 

If you have Go 1.19+, you can directly install Cosign by running:

```
go install github.com/sigstore/cosign/cmd/cosign@latest
```
The resulting binary will be placed at $GOPATH/bin/cosign (or $GOBIN/cosign, if set).

You can check different methods of installation in this [link](https://docs.sigstore.dev/cosign/installation/) 

## Generate a keypair

To generate a key pair in Cosign, run `cosign generate-key-pair`, you'll be interactively prompted to provide a password.
This command will generate private/public key pairs. The private key will be used to sign the image, and the public key will be used to verify the signature.

```
$ cosign generate-key-pair
Enter password for private key:
Enter again:
Private key written to cosign.key
Public key written to cosign.pub
```
NOTE: You can also use KMS providers like AWS KMS, Azure key vault, Google KMS, and HashiCorp vault to generate keys and sign images. You can also use openID connect to sign images.

## prepare image to be signed 

- Cosign doesn't sign local images, you will need access to a container registry for cosign to work with. In this example, I used docker hub registry.
- You must have a write permission on the container registry to add the digital signature to images.

For the demo purpose I will pull an nginx image from then tag it and push it to by private OCI registry.

```
docker pull nginx
docker tag nginx:latest josephyostos/dev-repo:signed 
docker login 
```

Let's sign the image. 

## siging the image 

At stage we will sign the image using the private key that we generated.

```
cosign sign --key cosign.key josephyostos/dev-repo:signed
```

Output 

>> add screenshot

now if you check the image in the registry it should has a sha256 digest 

>> add screenshot

## VVerify a container image against a public key

```
cosign verify --key cosign.pub josephyostos/dev-repo:signed | jq .
```

Output 

>> add screenshot

