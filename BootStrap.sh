# #!/bin/bash
set -e

echo $'BootStrap script initiating...\n'
echo $'Please provide AWS credentials:\n'
echo 'AWS-ACCESS-KEY-ID:'
read AWSACCESSKEYID
echo ""
echo  "AWS-SECRET-KEY:"
read AWSSECRETKEY
echo""
cd devops/terraform
terraform plan -var="access_key=$AWSACCESSKEYID" -var="secret_key=$AWSSECRETKEY"
terraform apply -var="access_key=$AWSACCESSKEYID" -var="secret_key=$AWSSECRETKEY"
echo "Setting Kubctl config at location ~/.kube"
mkdir -p ~/.kube/
terraform output kubeconfig>~/.kube/config
cd ../k8s/helm/
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add keel-charts https://charts.keel.sh
helm repo update
echo "Deploying MongoDB.."
helm  upgrade --install mongo stable/mongodb -f mongo/values-dev.yaml
echo "Deploying traefik ingress controller"
helm upgrade --install  traefik stable/traefik --set rbac.enabled=true  --namespace kube-system
helm upgrade --install ctd ./ctd/ --debug
echo "Deploying Keel.sh.."
helm upgrade --install keel --namespace=kube-system keel-charts/keel --set helmProvider.enabled="false"
EXTERNAL_IP=`kubectl describe svc traefik --namespace kube-system | grep Ingress | awk '{print $3}'`
echo""
echo "Deployement Completed, create CNAME entry in DNS"
echo "$DOMAINNAME pointing to $EXTERNAL_IP"

