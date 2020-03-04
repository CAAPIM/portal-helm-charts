Welcome to the API Portal Helm Charts repository.

API Portal supports a Kubernetes Private Cloud deployment using preconfigured Portal Helm charts.

## Wiki
There's a wealth of instructional and reference information available for setting up API Portal on Kubernetes. See what's available from the [Wiki](https://github.com/CAAPIM/portal-helm-charts/wiki).

## License
Copyright (c) 2019 CA, A Broadcom Company. All rights reserved.

This software may be modified and distributed under the terms of the MIT license. See the [LICENSE](https://github.com/CAAPIM/portal-helm-charts/blob/master/LICENSE) file for details.


## New Version!
Take a look for the additional fields you can add in values.yaml

kubeNamespace has been renamed to subdomainPrefix to avoid confusion, there are also several other updates to improve the overall security, and ease of use.

When using Native Kubernetes you no longer need to update our templates directly, just set the controller and class in values.yaml and we'll take care of the rest.

Be sure to get the docker-secret.yaml and place it in templates ==> ftp://ftp.ca.com/pub/API_Management/API_Developer_Portal_Enhanced_Experience/CR/helm/docker-secret.yaml