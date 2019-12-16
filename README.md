Welcome to the API Portal Helm Charts repository.

API Portal supports a Bring Your Own Kubernetes (BYOK) deployment with a preconfigured Portal Helm chart. 

Review the following prior to starting:
* [Deployment Topology](#deployment-topology)
* [Supported Form Factors](#supported-form-factors)
* [Installation Workflow](#installation-workflow)

## Deployment Topology

![](https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/dita/ca-enterprise-software/layer7-api-management/api-developer-portal/apip44/topics/kube.png)

The following components are involved in the deployment:
* Portal Helm chart templates, which gather the latest Portal image and services.
* The **values.yaml** configuration file, which allows configuration of host names and other parameters. This file is comparable to **portal.conf** in a Docker Swarm deployment.
* Helm client and helm server (tiller), which deploys the chart onto a Kubernetes cluster.
* External supporting services such as external database and mail server.

## Supported Form Factors
These Kubernetes form factors have been tested and are officially supported:
* Google Kubernetes Engine (GKE)
* OpenShift Origin Community Distribution of Kubernetes Platform 3.11

## Installation Workflow
The following is a recommended workflow for installing API Portal in a Kubernetes cluster:

![](https://techdocs.broadcom.com/content/dam/broadcom/techdocs/us/en/dita/ca-enterprise-software/layer7-api-management/api-developer-portal/apip44/topics/helmworkflow.png)

> Installation instructions available at the [API Portal Helm Charts Wiki](https://github.com/CAAPIM/portal-helm-charts/wiki). 
