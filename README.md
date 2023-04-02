
<h3 align="center">GoViolin</h3>

## Table of contents :
- [Introuduction](#introduction-)
- [Tools](#tools-)
- [Diagram](#diagram-)
- [Set the Project](#set-the-project-)
- [Run The Pipeline](#run-the-piplinr)

## Introduction : 

In this project, a website written in GO named GoViolin was deployed on a Kubernetes cluster. a Jenkins pipeline and a Nexus local repository were created in separate namespace within the Kubernetes cluster. The Jenkins pipeline will automate the build and deployment of our application, while the Nexus repository will serve as a centralized location for storing and managing our Docker images.

By following the project, you will have a fully functional website deployment on Kubernetes with a streamlined CI/CD pipeline

## Tools : 
<a href="https://www.jenkins.io" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg" alt="jenkins" width="40" height="40"/> </a> <a href="https://www.docker.com/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="docker" width="40" height="40"/> </a>
<a><img src="https://assets-global.website-files.com/5f10ed4c0ebf7221fb5661a5/5f2af61146c55b6e172fa5b3_NexusRepo_Icon.png" alt="Ansible" width="40" height="40"/> </a>
<a><img src="https://juststickers.in/wp-content/uploads/2018/11/kubernetes-wordmark.png" alt="Ansible" width="40" height="40"/> </a>

## Diagram : 
 <p align="center">
<img  src="https://user-images.githubusercontent.com/69608603/229364110-19698991-699d-4f59-a1a8-b436388c21cd.png" alt="centered image" >
</p>


## Set the Project: 



minikube start

### Create the Nexus repository manager
```bash
cd manifests/nexus/
kubectl apply -f .
```
### Check Nexus pods 
```bash
 kubectl get pods
```
### Add nexus HTTPS certificate to minikube
```bash
minikube ssh 'sudo mkdir /etc/docker/certs.d/nexus:8082'
minikube cp registry.crt /etc/docker/certs.d/nexus:8082/ca.crt
minikube ssh 'ls  /etc/docker/certs.d/nexus:8082/ca.crt'
```
### Add DNS values in the host machine in order to access Jenkins and Nexus dashboards from browser
```bash
sudo sh -c "echo '<<minikube ip >> jenkins.dashboard nexus.dashboard goviolin.com  ' >> /etc/hosts"
sudo sh -c "echo ' <<nexus service ip >> nexus'  >> /etc/hosts"
```
### Create ingress rules to access Nexus and Jenkins using HTTPS through NGINX controller
```bash
cd manifests/ingress/
kubectl apply -f  .
```
### enable NGINX controller in minikube
```bash
minikube addons enable ingress
```
### Create a minikube tunnelling to access the Kubernates cluster from the host machine
```bash
minikube tunnel
```

### Access nexus dashboard from the Host Machine
  the URL of Nexus dashboard : https://nexus.dashboard/
  To login, you need a password that resides in the nexus pod, you can get it using this command:
  ```bash
  kubectl exec nexus-0 -c nexus -- cat /nexus-data/admin.password
  ```
  change the password and make sure to set the same password in Jenkins Pipline,also enable "Enable anonymous access"

create a hosted docker hosted in https port 8082 , enable anonymous pull , in realms  enable docker bearer token

### create the Jenkins image and push it in nexus
```bash
cd JenkinsImage/
docker build -t nexus:8082/jenkins:latest .

docker login nexus:8082 -u admin -p admin

docker push nexus:8082/jenkins:latest

cd manifests/jenkins

kubectl apply -f .
```
### check that jenkins pod are working
kubectl  get pods

### Access jenkins dashboard :
    https://jenkins.dashboard
    Jenkins user : hamdy
    Jenkins pass : VTG266iFe4QfEBYL2eNRHH

### Run GoViolin Website
```bash
 cd app/
 docker build -t nexus:8082/goviolin .
 docker push nexus:8082/goviolin
```
```bash
 cd manifests/GoViolin/
 kubectl apply -f . -n app
```
### Access the Website:
    https://goviolin.com/























