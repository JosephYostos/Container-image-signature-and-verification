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
