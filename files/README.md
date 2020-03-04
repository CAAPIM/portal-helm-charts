# Portal Certificates

The [create_self_signed_certs.sh](../scripts) script with generate self-signed variants of all the necessary certificates. The file-extensions are as follow:

| File extension | Description |
| --- | --- |
| .crt | PEM-format SSL certificate |
| .key | PEM-format SSL private key |
| .p12 | PKCS12 encrypted certificate and private key bundle |

The table below indicates the file format of the certificates ingested by API Portal containers.

| Filename | Format | Container(s) | Public | Description |
| --- | --- | --- | --- | --- |
| analytics.crt | PEM | analytics-server | | server-side certificate |
| analytics.key | RSA key | analytics-server | | server-side key |
| apim-datalake.p12 | PKCS12 encrypted | apim/ingress, pssg | | for Datalake service |
| apim-dssg.p12 | PKCS12 encrypted | apim/ingress, pssg | | for DSSG service |
| apim-solr.crt | PEM | apim/ingress | |  for SOLR indexing API |
| apim-ssl.p12 | PKCS12 encrypted | apim/ingress | Yes | server-side certificate |
| apim-tps.crt | PEM | apim/ingress | |  for tenant provisioning API |
| dispatcher-ssl.p12 | PKCS12 encrypted | dispatcher | Yes |  API Portal subdomain SSL certificate |
| pssg-ssl.p12 | PKCS12 encrypted | apim/ingress, pssg | Yes |  server-side certificate |
| smtp-internal.crt | PEM | smtp | | server-side certificate |
| smtp-internal.key | PEM | smtp | | server-side key |
| smtp-internal.pem | PEM | smtp | | CA signing certificate |
| tps.crt | PEM | tenant-provisioner | |  server-side certificate |
| tps.key | RSA key | tenant-provisioner | |  server-side key |
|  |  |  |  |

Certificates with "-ssl" suffix are publicly facing and should be CA-signed for production systems.

## Replacing certificates

1. Overwrite the default file in this directory 
2. If the import password and PEM passphrase has changed, update values.yaml
3. Re-deploy the application
