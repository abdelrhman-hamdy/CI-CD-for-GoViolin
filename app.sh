#!/bin/bash
cd app/

docker build -t nexus:8082/goviolin .
docker push nexus:8082/goviolin

cd ../manifests/goviolin/

kubectl get namespace  | grep app --quiet
if [ $? -ne 0 ]; then 
kubectl create namespace app
fi 

kubectl get pods  -n app | grep goviolin --quiet
if [ $? -eq 0 ]; then 
kubectl delete -f . -n app
fi 
kubectl apply -f . -n app

app_state=''

while [ "${app_state}" != "Running" ] && [ "${app_state}" != "Error" ] ;do

app_state=$(kubectl get pods -n app | grep goviolin | tr -s ' ' |  cut -d" " -f3)
echo "Still creating goviolin Pod..."
echo "goviolin pod state : ${app_state}"
sleep 5
done 

if [[ "${app_state}" = 'Running' ]]; then
 echo "The goviolin pod is UP and Running"

else 
    echo "Failed to Create the  goviolin pod"
    echo "Quiting..."
    exit 1
 fi