# P2P.org App

## Overview
This project provides a comprehensive setup for deploying a Kubernetes-based environment on your local machine. It leverages tools like Helm for kubernetes resource management and ArgoCD for continuous delivery.

---

## Prerequisites

Before you start, ensure you have the following installed on your local computer:

1. [Kind](https://kind.sigs.k8s.io/) for running a local Kubernetes cluster.
2. [kubectl](https://kubernetes.io/docs/tasks/tools/) – Kubernetes command-line tool.
3. [Helm](https://helm.sh/docs/intro/install/) – Kubernetes package manager.
4. [Git](https://git-scm.com/) – Version control system.

---

## Setup Instructions

### 1. Deploy Kubernetes Cluster Locally
```bash
# This install kind, kubectl, helm and create a kind cluster
./deploy.sh
#Check access to the cluster
kubectl cluster-info

Kubernetes control plane is running at https://127.0.0.1:35841
CoreDNS is running at https://127.0.0.1:35841/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

```

#### Deploy ARGOCD in to the cluster
1. Enable the Kubernetes feature in Docker Desktop.
```bash
cd charts/argo-cd
helm repo add redis https://dandydeveloper.github.io/cha
helm dependency build
helm install argocd . -f values.yaml 
```
2. Verify installation 
```bash
kubectl get pods -n argocd
    NAME                                                READY   STATUS    RESTARTS      AGE
    argocd-application-controller-0                     1/1     Running   0             25h
    argocd-applicationset-controller-7bcd6d4dcc-7cxxh   1/1     Running   0             25h
    argocd-dex-server-6cbccb8d68-9tssc                  1/1     Running   1 (25h ago)   25h
    argocd-notifications-controller-f798bbb4b-thq4p     1/1     Running   0             25h
    argocd-redis-65fc86ddfc-njbld                       1/1     Running   0             25h
    argocd-repo-server-848845c4c6-qclkm                 1/1     Running   4 (25h ago)   25h
    argocd-server-5fb969f99-hnkqt                       1/1     Running   4 (25h ago)   25h

kubectl port-forward service/argocd-server -n argocd 9090:443
```
3- Navigate to localhost:9090 on your browser. username: admin, password you can run
``` bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
``` 
4 - Deploy argocdworkloads 
```bash
kubectl apply -f argocd-workloads/p2p-app-dev.yml
kubectl apply -f argocd-workloads/p2p-app-prod.yml

kubectl get applicationsets -n argocd
NAME           AGE
p2p-app-dev    15h
p2p-app-prod   5m52s

```

4 - Test application are deployd and work.
``` bash
 kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
p2p-app-main-dev-b7f7fb579-z5x9p     1/1     Running   0          13h
p2p-app-main-prod-6bb4857b77-2z87f   1/1     Running   0          23s
p2p-app-main-prod-6bb4857b77-st8pf   1/1     Running   0          10m

kubectl port-forward service/p2p-app-main-dev  6060:3000
Forwarding from 127.0.0.1:6060 -> 3000
Forwarding from [::1]:6060 -> 3000

curl localhost:6060
Hello, you've requested: /
```
## How to deploy a new version?
1.  Merge new code into develop or master. Github action will deploy a new tag and push the image to javiee/p2p docker registry.
     [Github action](https://github.com/javiee/p2p/actions/) 
2.  Commit a new tag into tag
       - [dev](https://github.com/javiee/p2p/blob/main/p2p-app/charts/values-dev.yaml/) 
       -  [prod](https://github.com/javiee/p2p/blob/main/p2p-app/charts/values-prod.yaml) 


## TODO and future enhacements
1. Create repo for p2p-app and argoworkloads
2. Deploy helm chart to an internal registry
3. Deploy[Image Updater](https://argocd-image-updater.readthedocs.io/en/stable/) to automate the manual step between build and argocd deploy.
4. Track version within the project.
5. Include test and docker scan phases in the pipeline
6. Enhace CI/CD stages to conditionally run to merge request, merge, feature /hotfix branch etc.