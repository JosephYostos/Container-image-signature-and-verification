

## 1. Install Cosign 

If you have Go 1.19+, you can directly install Cosign by running:

```
go install github.com/sigstore/cosign/cmd/cosign@latest
```
The resulting binary will be placed at $GOPATH/bin/cosign (or $GOBIN/cosign, if set).

You can check different methods of installation in this [link](https://docs.sigstore.dev/cosign/installation/) 

## 2. Generate a keypair

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

## 3. prepare image to be signed 

- Cosign doesn't sign local images, you will need access to a container registry for cosign to work with. In this example, I used docker hub registry.
- You must have a write permission on the container registry to add the digital signature to images.

For the demo purpose I will pull an nginx image from then tag it and push it to by private OCI registry.

```
docker pull nginx
docker tag nginx:latest josephyostos/dev-repo:signed 
docker login 
```

Let's sign the image. 

## 4. siging the image 

At stage we will sign the image using the private key that we generated.

```
cosign sign --key cosign.key josephyostos/dev-repo:signed
```

Output 

>> add screenshot

now if you check the image in the registry it should has a sha256 digest 

>> add screenshot

## 5. VVerify a container image against a public key

```
cosign verify --key cosign.pub josephyostos/dev-repo:signed | jq .
```

Output 

>> add screenshot

