#!/bin/bash

read -p 'Please Enter Nexus username : ' NEXUS_USER
read -p 'Please Enter Nexus password : ' NEXUS_PASS

cd JenkinsImage/

# Build Jenkins docker image
docker build -t nexus:8082/jenkins:latest .

# Trust the nexus certificate in the docker installed in the host machine

docker login nexus:8082 -u ${NEXUS_USER} -p ${NEXUS_PASS}
if [ $? -nq 0 ]; then 
 echo 'ERROR: Could not connect to The reposistory '
 echo 'Quitting...'
 exit 1 
fi 

docker push nexus:8082/jenkins:latest

cd ../manifests/jenkins

kubectl get pods  | grep jenkins --quiet
if [ $? -eq 0 ]; then 
kubectl delete -f .
fi 
kubectl apply -f . 

jenkins_state=''
while [ "${jenkins_state}" != "Running" ] && [ "${jenkins_state}" != "Error" ] && [ "${jenkins_state}" != 'Init:Error' ]  ;do

jenkins_state=$(kubectl get pods | grep jenkins | tr -s ' ' |  cut -d" " -f3)
echo "Still creating Jenkins Pod..."
echo "Jenkins pod state : ${jenkins_state}"
sleep 5
done 

if [[ "${jenkins_state}" = 'Running' ]]; then
 echo "The Jenkins pod is UP and Running"

else 
    echo "Failed to Create the  Jenkins pod"
    echo "Quiting..."
    exit 1
 fi