# Devops Readme

![Push image to ECS](https://github.com/vady-htop/coding-task-devops/workflows/Docker%20build%20and%20push%20image%20to%20ECR/badge.svg?branch=master) 

## Table of contents
* [Introduction](#introdcution)
* [Technologies and Tools](#technologies-and-tools)
* [ Getting Started](#getting-started)
* [Contact](#contact)

## Introduction
These instructions will get the project up and running on [AWS EKS](https://aws.amazon.com/eks/). 

## Technologies and Tools
* [Helm v3](https://helm.sh/)
* [Terraform v0.12.20](https://www.terraform.io/)
* [Keel](https://keel.sh/)
* [Kubernetes](https://kubernetes.io/)


## Getting Started 
Before starting make sure you have installed following packages.    
* [Helm](https://helm.sh/docs/intro/install/) 
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Provisioning AWS infrasructure.
Clone the repo and initiate terraform:
```sh
$ git clone https://github.com/vady-htop/coding-task-devops.git
$ cd coding-task-devops/devops/terraform/
$ terraform init
```

Provide AWS credentials in the file terraform/variables.tf.

```
variable "access_key" {
     default = "PLACE YOUR AWS KEY HERE"
}
variable "secret_key" {
     default = "PLACE YOUR AWS SECRET"
}
```

Run terraform to create an execution plan.

```sh
$ terraform plan
```

Finally apply terraform which will create required AWS infastructure which includes VPC, Subnets, IAM Roles,
Secuirity Groups, and Amazon EKS - Managed Kubernetes Service.

```sh
$ terrafrom apply
```
Above command should take approxiamtely 12 minutes to provision your kubernetes cluster.

#### Setting kubectl config.

You will need the configuration output from Terraform in order to use kubectl to interact with your new cluster. Create your kube configuration directory, and output the configuration from Terraform into the config file using the Terraform output command:
```sh
$ mkdir ~/.kube/
$ terraform output kubeconfig>~/.kube/config
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.3", GitCommit:"06ad960bfd03b39c8310aaf92d1e7c12ce618213", GitTreeState:"clean", BuildDate:"2020-02-13T18:06:54Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"14+", GitVersion:"v1.14.9-eks-c0eccc", GitCommit:"c0eccca51d7500bb03b2f163dd8d534ffeb2f7a2", GitTreeState:"clean", BuildDate:"2019-12-22T23:14:11Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
```

## CI/CD arrchitecture.
![Acrhitecture Diagram](https://github.com/vady-htop/coding-task-devops/blob/master/images/CICD.jpg)

Each change on the master Git branch triggers Github action **Bump Version** and the action will:
* Get latest tag
* Bump tag with minor version unless any commit message contains #major or #patch
* Pushes tag to github

Once tag is pushed it triggers **Docker build and push image to ECR** Github action and the action will:
* Build the docker container and pushes to ECR.

[Keel](https://keel.sh/) -It keeps polling the ECR registry. In application deployment.yaml file where we instruct Keel to track and update specific values whenever there is a new version.  Following [semver](http://semver.org/) best practices allows you to safely automate application updates.
Policy **all** updates application whenever there is a version bump or a new prerelease created (ie: 1.0.0 -> 1.0.1-rc1)

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "ctd.fullname" . }}
  labels:
    {{- include "ctd.labels" . | nindent 4 }}
  annotations:
    keel.sh/policy: all
    keel.sh/trigger: poll
```
#### Deploying MongoDB using Helm
Go to devops/k8s/helm directory and follow the steps.

```sh
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
$ helm repo update
$ helm install mongo stable/mongodb -f mongo/values-dev.yaml
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
mongo-mongodb-787f4cc67c-4hgml   1/1     Running   0          9m11s
```
`Note`: If you want to deploy Mongo in Production env use values-production.yaml file which creates replica and arbiter.

#### Deploying ingress controller traefik CTD web-app
```sh
$ helm install traefik stable/traefik --set rbac.enabled=true  --namespace kube-system
$ kubectl get svc traefik --namespace kube-system -w
NAME      TYPE           CLUSTER-IP     EXTERNAL-IP                                                               PORT(S)                      AGE
traefik   LoadBalancer   172.20.22.20   a716b22ce565b11ea8b6d0e0d8aa0590-1370736595.us-east-1.elb.amazonaws.com   443:31998/TCP,80:31455/TCP   4m45s  a5c431d12564b11eaaad302d3ac040a1-1588837981.us-east-1.elb.amazonaws.com   443:31136/TCP,80:30850/TCP   2m8s
$ helm upgrade --install ctd ./ctd/
```
Create CNAME for the app which points to EXTERNAL-IP of traefik

### Deploy Keel 

```sh
$ helm repo add keel-charts https://charts.keel.sh 
$ helm repo update
$ helm upgrade --install keel --namespace=kube-system keel-charts/keel --set helmProvider.enabled="false"
$  kubectl --namespace=kube-system get pods -l "app=keel"
NAME                    READY   STATUS    RESTARTS   AGE
keel-66cfd9dc58-hfhf7   0/1     Running   0          25s
$ kubectl logs -f keel-66cfd9dc58-hfhf7 -n kube-system
 image="ctd-web-app:0.2.0" job_name=613218033618.dkr.ecr.us-east-1.amazonaws.com/ctd-web-app schedule="@every 1m"
```
### Running BootStrap script 
#### What it does?
Bootstrap kubernetes cluster with all services needed to run the application
You need supply AWS credentials.
```sh
$ chmod +x $ BootStrap.sh
$ ./BootStrap.sh
Please provide AWS credentials:

AWS-ACCESS-KEY-ID:
ASDSASXXXXX

AWS-SECRET-KEY:
isdasdsa+xxxxxxxxxx
```

## Contact
Created by [Vady](www.linkedin.com/in/vady) - feel free to contact me!


