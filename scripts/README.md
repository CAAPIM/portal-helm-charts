# Helper Scripts
## create_self_signed_certs.sh 

Script to generate all non public facing self-signed certs in specified location.
This script has no parameters, it will ask you to provide a password to protect those certs and folder location to store those certs.

Usage notes:
- the **subdomain** value provided should be identical to ```user.domain``` in ```values.yaml```. This will generate an SSL wildcard certificate in the form of \*.<user.domain> for the dispatcher container.

**Mac clients**: Ensure that you have the *v3_ca* extension defined in ```/etc/ssl/openssl.cnf``` for certificate generation

```
[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
```
**To run the script:  create_self_signed_certs.sh 

**To run the script with parameters, the following options are supported:
1. -l: Location of the helm charts files directory
1. -s: Subdomain of the portal
1. -p: Certificate password
