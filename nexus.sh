#!/bin/bash
minikube start 

cd manifests/nexus

kubectl get pods  | grep nexus --quiet

if [ $? -eq 0 ]; then 
kubectl delete -f .
fi 

kubectl apply -f .

minikube ssh 'sudo mkdir -p /etc/docker/certs.d/nexus:8082'
minikube cp registry.crt /etc/docker/certs.d/nexus:8082/ca.crt
minikube ssh 'ls  /etc/docker/certs.d/nexus:8082/ca.crt'


minikube_ip=$(minikube ip)

echo  The Minikube IP  :  ${minikube_ip} 

nexus_service_ip=$(kubectl get svc | grep nexus | tr -s ' ' |  cut -d" " -f3)

echo The Nexus Service IP : ${nexus_service_ip}

nexus_State=''
while [ "${nexus_State}" != "Running" ] && [ "${nexus_State}" != "Error" ] && [ "${nexus_State}" != 'Init:Error' ]  ;do

nexus_State=$(kubectl get pods | grep nexus | tr -s ' ' |  cut -d" " -f3)
echo "Still creating Nexus Pod..."
echo "Nexus pod state : ${nexus_State}"
sleep 5
done 

if [[ "${nexus_State}" = 'Running' ]]; then
 echo "The Nexus pod is UP and Running"

else 
    echo "Failed to Create the  Nexus pod"
    echo "Quiting..."
    exit 1
 fi

cd ../ingress/
kubectl apply -f  .

minikube addons enable ingress
