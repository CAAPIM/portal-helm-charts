{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "portal.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the license file required by the portal
*/}}
{{- define "portal-license" -}}
{{- $f:= (.Files.Get "files/License.gz")  }}
{{- if empty $f }}
{{- fail "Please place the gziped SSG license in the files directory" }}
{{- else }}
{{- print $f }}
{{- end }}
{{- end -}}

{{/*
Get the jarvis cert file
*/}}
{{- define "jarvis-crt" -}}
    {{- $f:= (.Files.Get "files/jarvis.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place jarvis.crt in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the analytics container SSL certificate
*/}}
{{- define "analytics-crt" -}}
    {{- $f:= (.Files.Get "files/analytics.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place the analytics container SSL certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the analytics container SSL private key
*/}}
{{- define "analytics-key" -}}
    {{- $f:= (.Files.Get "files/analytics.key")  }}
    {{- if empty $f }}
        {{- fail "Please place the analytics container SSL key in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the apim container Datalake Service SSL certificate
*/}}
{{- define "apim-datalake" -}}
    {{- $f:= (.Files.Get "files/apim-datalake.p12")  }}
    {{- if empty $f }}
        {{- fail "Please place the apim-datalake PKCS12 certificate and key bundle in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the apim container DSSG Service SSL certificate
*/}}
{{- define "apim-dssg" -}}
    {{- $f:= (.Files.Get "files/apim-dssg.p12")  }}
    {{- if empty $f }}
        {{- fail "Please place the apim-dssg PKCS12 certificate and key bundle in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the apim container SOLR certificate
*/}}
{{- define "apim-solr-crt" -}}
    {{- $f:= (.Files.Get "files/apim-solr.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place the apim container SOLR certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the apim container Tenant Provisioning Service certificate
*/}}
{{- define "apim-tps-crt" -}}
    {{- $f:= (.Files.Get "files/apim-tps.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place the apim container tenant provisioning certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the apim container SSL certificate and private key bundle
*/}}
{{- define "apim-ssl" -}}
    {{- $f:= (.Files.Get "files/apim-ssl.p12")  }}
    {{- if empty $f }}
        {{- fail "Please place the apim container PCKS12 SSL certificate and key bundle in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the dispatcher container SSL certificate and private key bundle
*/}}
{{- define "dispatcher-ssl" -}}
    {{- $f:= (.Files.Get "files/dispatcher-ssl.p12")  }}
    {{- if empty $f }}
        {{- fail "Please place the dispatcher container PKCS12 SSL certificate and key bundle in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the pssg container SSL certificate and key bundle
*/}}
{{- define "pssg-ssl" -}}
    {{- $f:= (.Files.Get "files/pssg-ssl.p12")  }}
    {{- if empty $f }}
        {{- fail "Please place the PSSG PKCS12 SSL certificate and key bundle in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get a user provided SMTP certificate
*/}}
{{- define "smtp-external-crt" -}}
    {{- $f:= (.Files.Get .Values.user.smtpCert)  }}
    {{- if empty $f }}
        {{- fail "Please place the external SMTP SSL certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the smtp container SSL certificate
*/}}
{{- define "smtp-internal-crt" -}}
    {{- $f:= (.Files.Get "files/smtp-internal.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place SMTP Postfix SSL certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the smtp container SSL private key
*/}}
{{- define "smtp-internal-key" -}}
    {{- $f:= (.Files.Get "files/smtp-internal.key")  }}
    {{- if empty $f }}
        {{- fail "Please place the SMTP Postfix SSL key in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the smtp container CA pem
*/}}
{{- define "smtp-internal-ca-pem" -}}
    {{- $f:= (.Files.Get "files/smtp-internal-ca.pem")  }}
    {{- if empty $f }}
        {{- fail "Please place the SMTP Postfix CA pem in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the smtp container SSL private key
*/}}
{{- define "tps-crt" -}}
    {{- $f:= (.Files.Get "files/tps.crt")  }}
    {{- if empty $f }}
        {{- fail "Please place the tenant-provisioner (tps) SSL certificate in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get the tps container SSL private key
*/}}
{{- define "tps-key" -}}
    {{- $f:= (.Files.Get "files/tps.key")  }}
    {{- if empty $f }}
        {{- fail "Please place the tenant-provisioner (tps) SSL key in the files directory" }}
    {{- else }}
        {{- print $f }}
    {{- end }}
{{- end -}}

{{/*
Get "portal" database name
*/}}
{{- define "portal-db-name" -}}
    {{ if .Values.user.legacyDatabaseNames }}
        {{- print "portal" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "portal" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get "otk" database name
*/}}
{{- define "otk-db-name" -}}
    {{ if .Values.user.legacyDatabaseNames }}
        {{- print "apim_otk_db" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "otk_db" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get "rbac" database name
*/}}
{{- define "rbac-db-name" -}}
    {{ if .Values.user.legacyDatabaseNames }}
        {{- print "rbac" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "rbac" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get "tenant provisioning" database name
*/}}
{{- define "tps-db-name" -}}
    {{ if  .Values.user.legacyDatabaseNames }}
        {{- print "tenant_provisioning" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "tenant_provisioning" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get "ldds" database name
*/}}
{{- define "ldds-db-name" -}}
    {{- if .Values.user.legacyDatabaseNames }}
        {{- print "lddsdb" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "lddsdb" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}


{{/*
Get "druid" database name
*/}}
{{- define "druid-db-name" -}}
    {{ if .Values.user.legacyDatabaseNames }}
        {{- print "druid" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "druid" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get "analytics" database name
*/}}
{{- define "analytics-db-name" -}}
    {{ if .Values.user.legacyDatabaseNames }}
        {{- print "analytics" }}
    {{- else }}
        {{- $f:= .Values.user.kubeNamespace -}}
        {{ if empty $f }}
            {{- fail "Please define kubeNamespace in values.yaml" }}
        {{- else }}
            {{- printf "%s_%s" $f "analytics" | replace "-" "_" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Portal Docops page
*/}}
{{- define "portal.help.page" -}}
{{- printf "%s" "https://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/api-developer-portal/4-5.html" -}}
{{- end -}}

{{/*
Generate a unique "default-tenant-id" appended with the kubeNamespace to enable multiple deployments on
one k8s cluster
*/}}
{{- define "default-tenant-id" -}}
    {{- $f:= .Values.user.defaultTenantId -}}
        {{ if empty $f }}
            {{- fail "Please define defaultTenantId in values.yaml" }}
    {{- else }}
        {{- if .Values.user.legacyHostnames }}
            {{- printf .Values.user.defaultTenantId | replace "_" "-" -}}
        {{- else }}
            {{- printf "%s-%s" .Values.user.defaultTenantId .Values.user.kubeNamespace | replace "_" "-" -}}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Generate Ingress SSG endpoint based on configurations
*/}}
{{- define "tssg-public-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "ssg.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-ssg.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate Rabbit MQ endpoint based on configurations
*/}}
{{- define "broker-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "broker.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-broker.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate PSSG enrolment endpoint based on configurations
*/}}
{{- define "pssg-enroll-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "enroll.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-enroll.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate PSSG sync endpoint based on configurations
*/}}
{{- define "pssg-sync-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "sync.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-sync.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate PSSG SSO endpoint based on configurations
*/}}
{{- define "pssg-sso-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "sso.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-sso.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate analytics endpoint based on configurations
*/}}
{{- define "analytics-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "analytics.%s" .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-analytics.%s" .Values.user.kubeNamespace  .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Generate default tenant endpoint based on configurations
*/}}
{{- define "default-tenant-host" -}}
    {{- if .Values.user.legacyHostnames }}
        {{- printf "%s.%s" .Values.user.defaultTenantId .Values.user.domain -}}
    {{- else }}
        {{- printf "%s-%s.%s" .Values.user.defaultTenantId .Values.user.kubeNamespace .Values.user.domain -}}
    {{- end }}
{{- end -}}

{{/*
Get "database-port" based on databaseType value

Override logic:
{{- define "database-port" -}}
    {{- print "<PORT NUMBER>" -}}
{{- end -}}

*/}}
{{- define "database-port" -}}
    {{ if .Values.user.setupDemoDatabase }}
        {{- $f:= .Values.user.databaseType -}}
        {{ if empty $f }}
            {{- fail "Please define databaseType in values.yaml" }}
        {{- else }}
            {{- if eq .Values.user.databaseType "postgresql" -}}
                {{- print "5432" -}}
            {{- end }}
            {{- if eq .Values.user.databaseType "mysql" -}}
                {{- print "3306" -}}
            {{- end }}
        {{- end }}
    {{- else }}
        {{- print .Values.user.databasePort -}}
    {{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zookeeper.name" -}}
{{- default .Values.zookeeper.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zookeeper.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zookeeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The name of the zookeeper headless service.
*/}}
{{- define "zookeeper.headless" -}}
{{- printf "%s-headless" (include "zookeeper.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "minio.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
 Ingress domain hosts
*/}}
{{- define "get-ingress-hosts" -}}
    {{- $f:= .Values.user.domain -}}
    {{ if empty $f }}
        {{- fail "Please define domain in values.yaml" }}
    {{- else }}
        {{- printf "*.%s" .Values.user.domain }}
    {{- end }}
{{- end -}}
