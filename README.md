# APIM Portal Helm Chart

This helm chart deploys APIM Portal to a Kubernetes platform. 

## Prerequisites
### Prerequisites - Client
1. [Kubectl installed](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 
2. [Helm installed](https://helm.sh/docs/intro/install/)

### Prerequisites - Platform
1. One of the following Kubernetes platform readily available (with tiller version >=2.8.0)

    - Openshift 3.11 (OKD)
    
    - Google Kubernetes Engine 
2. The platform has minimum of 32G memory available
4. If firewall enabled, portal required ports open on the cluster nodes: 8443, 9443

### Prerequisites - For Production
1. External tenant domain ingress certs
2. External MySQL database instance
3. Optional: private docker registry if not pulling image from default ca apim bintray

## Deployment
### Step by Step Deployment process
1. Use one of the following kubernetes platform
 
       - OKD (Openshift) 
       - GKE (Google Kubernetes Engine)
2. In case of GKE platform - use existing Ingress controller if there is one already installed on your GKE platform or follow "Appendix A - Ingress Controller" section to install Ingress controller on GKE platform             
3. Place gateway License.gz file in `files` directory. If you have a license.xml, `gzip < license.xml > License.gz`
4. To generate self-signed certificates go to k8s-helm-portal/scripts folder and use [create_self_signed_certs.sh](scripts) using following command - `./create_self_signed_certs.sh`
5. (For production) Replace publicly facing certificates with CA-signed certificates
6. Edit values.yaml for user inputs (Refer Appendix B. Parameters table )
7. kubeNamespace inside values.yaml should be unique to your project.
8. From terminal go to k8s-helm-portal and Run following command to deploy helm charts - 

        helm install . 
9. Wait for all pods to come up. 
   Kubernetes users can check deployment status using following command:  
    
        kubectl get pods 
    
   While OpenShift users can use the oc binary equivalent:
    
        oc get pods
                
10. Add all API Portal routes to your DNS service. If the domain is not public, you will need to add all routes in the /etc/hosts file of any systems that need to talk to the API Portal
11. Verify that the API Portal can be accessed via ```https://<DEFAULT_TENANT_ID>-<NAMESPACE>.<PORTAL_DOMAIN>``` (i.e. https://apim-portal.example.com)
12. (Optional) Contact Broadcom/CA Support if you do not currently have login credentials to apim-portal.packages.ca.com
13. Update ```templates/docker-secret.yaml```

        export AUTH_STRING=$(echo "<USERNAME>:<PASSWORD>" | base64)
        export DOCKERCONFIGJSON=$(echo "{\"auths\":{\"apim-portal.packages.ca.com\":{\"auth\":\"$AUTH_STRING\"}}}" | base64 -w 0)
        echo "  .dockerconfigjson: $DOCKERCONFIGJSON" >> templates/docker-secret.yaml

    The docker-secrets.yaml file should look like below:
    
        apiVersion: v1
        kind: Secret
        metadata:
          name: bintray
        type: kubernetes.io/dockerconfigjson
        data:
          .dockerconfigjson: <Long base64 string with credentials>

## Creating A Tenant

### Step 1: Create a new tenant record

Pre-configure the tenant by constructing a JSON payload for the tenant creation API call. 
Tenant parameter definitions can be found at [Create the API Portal Tenant](https://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/api-developer-portal/4-4/install-configure-and-upgrade/post-installation-tasks/create-the-api-portal-tenant.html) in Broadcom TechDocs.
    
   Tenant creation payload: 
   ```
        {
                        "adminEmail": "YOUR-ADMIN-EMAIL",
                        "auditLogLevel": "TRACE",
                        "multiclusterEnabled": true,
                        "noReplyEmail":"noreply@YOUR-MAIL_DOMAIN",
                        "performanceLogLevel": "ERROR",
                        "portalLogLevel": "ERROR",
                        "portalName": "YOUR-PORTAL-NAME",
                        "subdomain": "YOUR-DOMAIN",
                        "tenantId": "YOUR-TENANT-NAME",
                        "tenantType": "ON-PREM",
                        "termOfUse": "eula"
        }
   ```
   Save the file as "payload.json".

**Post the JSON payload to the tenant creation API**
 
  The portal should be deployed using ```apim-tps.cert``` and ```apim-tps.key``` in the ```files``` directory.
  These files can be generated using the ```create_self_signed_certs.sh```

   POST request to create tenant using API ```https://<ingress SSG host>:<ingress SSG port>/provision/tenants```
   
   Example:
   ```
    curl -X POST -k https://ca-apim-ssg.example.com:443/provision/tenants --cert apim-tps.crt --key apim-tps.key -H "Accept: application/json" -H "Content-Type: application/json" -d "@./payload.json"
   ```
   A successful tenant creation will produce a response similar to the following:
   ```
    {"uuid":"5f2b152e-4272-41d1-a6b3-cc07ce6eb8ce","tenantId":"tenant1","portalName":"myportal","auditLogLevel":"TRACE",
    "performanceLogLevel":"ERROR","portalLogLevel":"ERROR","adminEmail":"email@ca.ca","noReplyEmail":"email@ca.ca",
    "tenantType":"ON-PREM","termOfUse":"EUlA","subdomain":"example.com","cqAuthorHost":null,"portalAppTenantI18NUri":"/admin/dict.json",
    "portalAppLoginUri":"/admin/login","portalAppHomeUri":"/admin/app/home","portalAppNavigationPrimaryUri":"/admin/navigation",
    "portalAppExtUserDashboardUri":"/admin/app/dashboard","portalAppLogoutDefaultTargetUri":"/homeRedirect",
    "portalAppMobileCSSUri":"","portalAppDesktopCSSUri":"","cqAuthorAuthUri":null,"status":"ACTIVE","hybridState":1,
    "portalHost":"tenant1.example.com"}
   ```

### Step 2: Expose tenant hostname

#### GKE
Route new API Portal homepage hostname through ingress-controller and portal-ingress in Kubernetes (example: tenant1.example.com)

Expose new created tenant in ingress controller
   ```
    - host: tenant1.example.com
      http:
        paths:
        - backend:
            serviceName: dispatcher
            servicePort: portal-https
   ```  
Add the route to tenant in your /etc/hosts
     
   ``` 
     portalIP tenant1.example.com
   ```

#### OKD
Create an OpenShift route object to the *dispatcher* service for the new tenant hostname ```https://<TENANT_ID>.<PORTAL_DOMAIN>```

### Step 3: Verify creation of new tenant

Login to the newly created tenant as the *admin* user
 
   In our example its "tenant1.example.com" and the login info will be the same as for admin
   
### Step 4: Enroll an API Gateway

Instructions can be found at [Enroll a CA API Gateway](https://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/api-developer-portal/4-4/install-configure-and-upgrade/post-installation-tasks/enroll-a-ca-api-gateway.html) in Broadcom TechDocs

## Appendix A: GKE Ingress Controller 
For the GKE deployment use Nginx or GCE Ingress controller - 

### 1. Nginx controller
	1. Deploy an Nginx controller with ssl passthrough enabled:
		```
		helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true --set controller.extraArgs.enable-ssl-passthrough=true --set tcp.9443="default/dispatcher:9443"
		```
	2. Enable GKE Ingress and turn off/disable openshift routes in k8s-helm-portal/values.yml
		```
		# GKE Ingress
		ingress:
			enabled: true

		route:
		  enabled: false
		```
	3. Configure Helm Charts to use Nginx ingress controller
		1. Go to k8s-helm-portal/templates/ingress.yaml 
		2. add the following under annotations:
			```
			annotations:
				kubernetes.io/ingress.class: nginx
			```
	

### 2. Default GCE controller
	1. Enable GKE Ingress and turn off openshift routes in k8s-helm-portal/values.yml
		```
		# GKE Ingress
		ingress:
		  enabled: true

		# Default for OpenShift. If deploying on GKE. Set route to false and ingress to true
		# Openshift Route
		route:
		  enabled: false
		```
	2. Configure the k8s-helm-portal/templates/dispatcher-service.yml
		1. add an additional annotation
			```
			annotations:
			    service.alpha.kubernetes.io/app-protocols: '{"{{ .Values.dispatcher.service.portName }}":"HTTPS"}'
			```
	3. Configure the k8s-helm-portal/templates/dispatcher-deployment.yml

		1. change the readiness & liveliness probe from executing a healthcheck inside the container to an httpGet & expose container port
			```
			readinessProbe:
			  httpGet:
			    path: /nginx_status
			    port: 8443
			    scheme: HTTPS
			  initialDelaySeconds: 60
			  timeoutSeconds: 5
			  periodSeconds: 15
			  successThreshold: 1
			livenessProbe:
			  httpGet:
			    path: /nginx_status
			    port: 8443
			    scheme: HTTPS
			  initialDelaySeconds: 300
			  timeoutSeconds: 5
			  periodSeconds: 15
			  successThreshold: 1
			ports:
			  - name: dispatcher
			    containerPort: 8443
			```
			
## Appendix B: values.yaml Parameters
| Key | Description | Default |
| --- | ------- | ----------- |
| `ingress` | Enable usage of Ingress on GKE | `false` |
| `analytics.replicaCount` | Number of analytics deployment | `1` |
| `analytics.dnsPolicy` | Analytics pod's DNS policy | `ClusterFirst` |
| `analytics.image.pullPolicy` | Analytics image pull policy | `Always` |
| `apim.replicaCount` | Number of APIM ingress deployment | `1` |
| `apim.dnsPolicy` | APIM ingress pod's DNS policy | `ClusterFirst` |
| `apim.image.pullPolicy` | APIM ingress image pull policy | `Always` |
| `asyncServer.replicaCount` | Number of async server deployment | `1` |
| `asyncServer.dnsPolicy` | Async server pod's DNS policy | `ClusterFirst` |
| `asyncServer.image.pullPolicy` | Async server image pull policy | `Always` |
| `authenticator.replicaCount` | Number of authenticator deployment | `1` |
| `authenticator.dnsPolicy` | Authenticator pod's DNS policy | `ClusterFirst` |
| `authenticator.image.pullPolicy` | authenticator image pull policy | `Always` |
| `dispatcher.replicaCount` | Number of dispatcher deployment | `1` |
| `dispatcher.dnsPolicy` | Dispatcher pod's DNS policy | `ClusterFirst` |
| `dispatcher.image.pullPolicy` | Dispatcher image pull policy | `Always` |
| `portalData.replicaCount` | Number of portal data deployment | `1` |
| `portalData.dnsPolicy` | Portal data pod's DNS policy | `ClusterFirst` |
| `portalData.image.pullPolicy` | Portal data image pull policy | `Always` |
| `portalEnterprise.replicaCount` | Number of portal enterprise deployment | `1` |
| `portalEnterprise.dnsPolicy` | Portal enterprise pod's DNS policy | `ClusterFirst` |
| `portalEnterprise.image.pullPolicy` | Portal enterprise image pull policy | `Always` |
| `portaldb.replicaCount` | Number of portal database deployment | `1` |
| `portaldb.dnsPolicy` | Portal database pod's DNS policy | `ClusterFirst` |
| `portaldb.image.pullPolicy` | Portal database image pull policy | `Always` |
| `pssg.replicaCount` | Number of PSSG deployment | `1` |
| `pssg.dnsPolicy` | PSSG pod's DNS policy | `ClusterFirst` |
| `pssg.image.pullPolicy` | PSSG image pull policy | `Always` |
| `rabbitmq.replicaCount` | Number of rabbitMQ deployment | `1` |
| `rabbitmq.dnsPolicy` | RabbitMQ pod's DNS policy | `ClusterFirst` |
| `rabbitmq.config.username` | RabbitMQ user | `user` |
| `rabbitmq.config.password` | RabbitMQ password | `7layereyal7` |
| `rabbitmq.config.host` | RabbitMQ host | `rabbitmq` |
| `rabbitmq.config.cookie` | RabbitMQ cookie | `L7Secure` |
| `rabbitmq.config.port` | RabbitMQ port | `5672` |
| `rabbitmq.config.rmq_default_user` | RabbitMQ default user | `user` |
| `rabbitmq.config.rmq_default_password` | RabbitMQ default password | `7layereyal7` |
| `rabbitmq.config.rmq_erlang_cookie` | RabbitMQ erlang cookie | `L7Secure` |
| `rabbitmq.image.pullPolicy` | RabbitMQ image pull policy | `Always` |
| `smtp.replicaCount` | Number of SMTP deployment | `1` |
| `smtp.dnsPolicy` | SMTP pod's DNS policy | `ClusterFirst` |
| `smtp.image.pullPolicy` | SMTP image pull policy | `Always` |
| `solr.replicaCount` | Number of solr deployment | `1` |
| `solr.dnsPolicy` | Solr pod's DNS policy | `ClusterFirst` |
| `solr.image.pullPolicy` | Solr image pull policy | `Always` |
| `tenantProvisioner.replicaCount` | Number of tenant provisioner deployment | `1` |
| `tenantProvisioner.dnsPolicy` | Tenant provisioner pod's DNS policy | `ClusterFirst` |
| `tenantProvisioner.image.pullPolicy` | Tenant provisioner image pull policy | `Always` |
| `minio.replicaCount` | Number of Minio deployment | `1` |
| `minio.dnsPolicy` | Minio pod's DNS policy | `ClusterFirst` |
| `minio.image.pullPolicy` | Minio image pull policy | `Always` |
| `minio.config.minioUrl` | Minio URL | `http://minio:9000` |
| `minio.config.minioAccessKey` | Minio Access Key | `minio` |
| `minio.config.minioSecretKey` | Minio Secret Key | `minio123` |
| `kafka.replicaCount` | Number of Kafka deployment | `1` |
| `kafka.dnsPolicy` | Kafka pod's DNS policy | `ClusterFirst` |
| `kafka.image.pullPolicy` | Kafka image pull policy | `Always` |
| `zookeeper.replicaCount` | Number of Zookeeper deployment | `1` |
| `zookeeper.dnsPolicy` | Zookeeper pod's DNS policy | `ClusterFirst` |
| `zookeeper.image.pullPolicy` | Zookeeper image pull policy | `Always` |
| `middlemanager.replicaCount` | Number of MiddleManager deployment | `1` |
| `middlemanager.dnsPolicy` | MiddleManager pod's DNS policy | `ClusterFirst` |
| `middlemanager.image.pullPolicy` | MiddleManager image pull policy | `Always` |
| `ingestion.replicaCount` | Number of Ingestion deployment | `1` |
| `ingestion.dnsPolicy` | Ingestion pod's DNS policy | `ClusterFirst` |
| `ingestion.image.pullPolicy` | Ingestion image pull policy | `Always` |
| `ingestion.config.partitionCount` | Kafka broker partitionCount | `1` |
| `broker.replicaCount` | Number of Broker deployment | `1` |
| `broker.dnsPolicy` | Broker pod's DNS policy | `ClusterFirst` |
| `broker.image.pullPolicy` | Broker image pull policy | `Always` |
| `coordinator.replicaCount` | Number of Coordinator deployment | `1` |
| `coordinator.dnsPolicy` | Coordinator pod's DNS policy | `ClusterFirst` |
| `coordinator.image.pullPolicy` | Coordinator image pull policy | `Always` |
| `historical.replicaCount` | Number of Historical deployment | `1` |
| `historical.dnsPolicy` | Historical pod's DNS policy | `ClusterFirst` |
| `historical.image.pullPolicy` | Historical image pull policy | `Always` |
| `image.portalRepository` | docker registry to pull image from | `apim-portal.packages.ca.com/apim-portal/` |
| `image.pullSecrets` | secret used to pull from docker registry, leave empty to use default in service account | `bintray` |
| `image.postgres` | postgres image | `postgres:latest` |
| `image.mysql` | mysql image | `mysqldb:latest` |
| `image.smtp` | smtp image | `smtp:latest` |
| `image.rabbitmq` | rabbitmq image | `message-broker:latest` |
| `image.dispatcher` | dispatcher image | `dispatcher:latest` |
| `image.pssg` | pssg image | `pssg:latest` |
| `image.apim` | apim ingress image | `ingress:latest` |
| `image.enterprise` | portal enterprise image | `portal-enterprise:latest` |
| `image.data` | portal data image | `portal-data:latest` |
| `image.tps` | tenant provisioner image | `tenant-provisioning-service:latest` |
| `image.solr` | solr image | `solr:latest` |
| `image.analytics` | analytics image | `analytics-server:latest` |
| `image.authenticator` | authenticator image | `authenticator:latest` |
| `image.asyncServer` | async server image | `async-server:latest` |
| `image.dbUpgrade` | db upgrade image | `db-upgrade-portal:latest` |
| `image.rbacUpgrade` | analytics image | `db-upgrade-rbac:latest` |
| `image.upgradeVerify` | upgrade verification image | `broadcomapim/upgrade-verify:1.0` |
| `user.kubeNamespace` | Kubernetes namespace for your own unique cluster | `ca_apim` |
| `user.legacyHostnames` | This is for MIGRATION ONLY, if enabled this will set your routes to use a tenant_id of `apim`, else it will use the kubeNamespace. | `false` |
| `user.legacyDatabaseNames` | This is for MIGRATION ONLY, if enabled this will set your portal containers to use the legacy databases (portal, apim_otk_db, etc), else it will use the kubeNamespace_<\database name> (portal, apim_otk_db, etc). | `false` |
| `user.Domain` | the url domain | `example.com` |
| `user.externalTenant` | the external tenant ID (this creates an ingress rule) |  |
| `user.analyticsEnabled` | set to true if using out-of-the-box analytics functionality, otherwise false | `true` |
| `user.ssoDebug` |  | `false` |
| `user.enrollNotificationEmail` | email to send for enrolment | `noreply@mail.example.com` |
| `user.setupDemoDatabase` | true to use provided database, false to edit subsequent database values to external database | `true` |
| `user.databaseHost` | database instance hostname | `portaldb` |
| `user.databasePort` | database instance connection port | auto-generated in `_helpers.tpl` |
| `user.databaseType` | "mysql" or "postgresql" | `mysql` |
| `user.databaseUsername` | database user | `admin` |
| `user.databasePassword` | database password | `7layer` |
| `user.setupInternalSMTP` | true to use provided smtp container, changing to false require subsequent smtp credentials (smtpHost & smtpPassword) to external smtp | `true` |
| `user.smtpHost` | smtp host | `smtp` |
| `user.smtpPassword` | smtp password | `supersecret` |
| `user.smtpPort` | smtp port | `25` |
| `user.smtpRequireSSL` | set to true if smtp require ssl, otherwise false | `true` |
| `user.smtpUsername` | smtp user | `superuser` |
| `user.hostnameWhitelist` |  |  |
| `user.defaultTenantId` | Do not change this unless you know what you are doing. You should always enroll an external tenant. | `apim` |
| `telemetry.telemetry_pla_enabled` | Set to true to turn on telemetry service, otherwise set to false by default. | `false` |
| `telemetry.telemetry_usage_type` | The telemetry service behaviour. If left empty, it will be set to PRODUCTION by default. | `NONPRODUCTION` |
| `telemetry.telemetry_domain_name` | Domain name of telemetry service. If left empty, it will be set to "unspecified" by default. |  |
| `telemetry.telemetry_site_id` | Site ID of telemetry service. If left empty, it will be set to "unspecified" by default. |  |
| `telemetry.telemetry_chargeback_id` | Chargeback ID of telemetry service. If left empty, it will be set to "unspecified" by default. |  |
| `telemetry.telemetry_proxy_url` | Required if customer is using a proxy to channel communications from installation to segment. |  |
| `telemetry.telemetry_proxy_username` | The proxy username. Required if the customer is using a secured proxy. |  |
| `telemetry.telemetry_proxy_password` | The proxy password. Required if the customer is using a secured proxy. |  |
| `secrets.apimSslKeyPass` | APIM ssl key password. This should be changed if you are using your own key. | `certpass` |
| `secrets.datalakeKeyPass` | Datalake key password. This should be changed if you are using your own key. | `certpass` |
| `secrets.dispatcherSslKeyPass` | Dispatcher ssl key password. This should be changed if you are using your own key. | `certpass` |
| `secrets.dssgKeyPass` | DSSG key password. This should be changed if you are using your own key. | `certpass` |
| `secrets.pssgSslKeyPass` | PSSG ssl key password. This should be changed if you are using your own key. | `certpass` |
| `secrets.tpsKeyPass` | TPS key password. This should be changed if you are using your own key. | `certpass` |
| `persistence.storage.name` | Persistence storage name | `standard` |
| `persistence.storage.historical` | Persistence storage volume for Historical | `100Gi` |
| `persistence.storage.minio` | Persistence storage volume for Minio | `200Gi` |
| `persistence.storage.kafka` | Persistence storage volume for Kafka | `50Gi` |
| `persistence.storage.zookeeper` | Persistence storage volume for Zookeeper | `2Gi` |

