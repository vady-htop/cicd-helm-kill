# Devops Readme

![Push image to ECS](https://github.com/vady-htop/coding-task-devops/workflows/Docker%20build%20and%20push%20image%20to%20ECR/badge.svg?branch=master) 

## Table of contents
* [Introduction](#introduction)
* [Screenshots](#screenshots)
* [Technologies and Tools](#technologies-and-tools)
* [ Getting Started](#getting-started)
* [Features](#features)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)

## Introdcution
These instructions will get you the project up and running on your [AWS EKS](https://aws.amazon.com/eks/). 

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

## CI/CD arrchitecture.
![Acrhitecture Diagram](https://github.com/vady-htop/coding-task-devops/blob/master/images/CICD.jpg)

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




## Code Examples
Show examples of usage:
`put-your-code-here`

## Features
List of features ready and TODOs for future development
* Awesome feature 1
* Awesome feature 2
* Awesome feature 3

To-do list:
* Wow improvement to be done 1
* Wow improvement to be done 2

## Status
Project is: _in progress_, _finished_, _no longer continue_ and why?

## Inspiration
Add here credits. Project inspired by..., based on...

## Contact
Created by [@flynerdpl](https://www.flynerd.pl/) - feel free to contact me!


Dillinger is a cloud-enabled, mobile-ready, offline-storage, AngularJS powered HTML5 Markdown editor.

  - Type some Markdown on the left
  - See HTML in the right
  - Magic

# New Features!

  - Import a HTML file and watch it magically convert to Markdown
  - Drag and drop images (requires your Dropbox account be linked)


You can also:
  - Import and save files from GitHub, Dropbox, Google Drive and One Drive
  - Drag and drop markdown and HTML files into Dillinger
  - Export documents as Markdown, HTML and PDF

Markdown is a lightweight markup language based on the formatting conventions that people naturally use in email.  As [John Gruber] writes on the [Markdown site][df1]

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text you see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.

### Tech

Dillinger uses a number of open source projects to work properly:

* [AngularJS] - HTML enhanced for web apps!
* [Ace Editor] - awesome web-based text editor
* [markdown-it] - Markdown parser done right. Fast and easy to extend.
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [Gulp] - the streaming build system
* [Breakdance](https://breakdance.github.io/breakdance/) - HTML to Markdown converter
* [jQuery] - duh

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.

### Installation

Dillinger requires [Node.js](https://nodejs.org/) v4+ to run.

Install the dependencies and devDependencies and start the server.

```sh
$ cd dillinger
$ npm install -d
$ node app
```

For production environments...

```sh
$ npm install --production
$ NODE_ENV=production node app
```

### Plugins

Dillinger is currently extended with the following plugins. Instructions on how to use them in your own application are linked below.

| Plugin | README |
| ------ | ------ |
| Dropbox | [plugins/dropbox/README.md][PlDb] |
| GitHub | [plugins/github/README.md][PlGh] |
| Google Drive | [plugins/googledrive/README.md][PlGd] |
| OneDrive | [plugins/onedrive/README.md][PlOd] |
| Medium | [plugins/medium/README.md][PlMe] |
| Google Analytics | [plugins/googleanalytics/README.md][PlGa] |


### Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantaneously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma test
```
#### Building for source
For production release:
```sh
$ gulp build --prod
```
Generating pre-built zip archives for distribution:
```sh
$ gulp build dist --prod
```
### Docker
Dillinger is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 8080, so change this within the Dockerfile if necessary. When ready, simply use the Dockerfile to build the image.

```sh
cd dillinger
docker build -t joemccann/dillinger:${package.json.version} .
```
This will create the dillinger image and pull in the necessary dependencies. Be sure to swap out `${package.json.version}` with the actual version of Dillinger.

Once done, run the Docker image and map the port to whatever you wish on your host. In this example, we simply map port 8000 of the host to port 8080 of the Docker (or whatever port was exposed in the Dockerfile):

```sh
docker run -d -p 8000:8080 --restart="always" <youruser>/dillinger:${package.json.version}
```

Verify the deployment by navigating to your server address in your preferred browser.

```sh
127.0.0.1:8000
```

#### Kubernetes + Google Cloud

See [KUBERNETES.md](https://github.com/joemccann/dillinger/blob/master/KUBERNETES.md)


### Todos

 - Write MORE Tests
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

## Technologies
   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
