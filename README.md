
<h3 align="center">GoViolin</h3>

## Table of contents :
- [Introuduction](#introduction-)
- [Tools](#tools-)
- [Diagram](#diagram-)
- [Set the Cluster](#set-the-cluster-)
- [Run The Pipeline](#run-the-piplinr)

## Introduction : 

In this project, a website written in GO named GoViolin was deployed on a Kubernetes cluster. a Jenkins pipeline and a Nexus local repository were created in a separate namespace within the Kubernetes cluster. The Jenkins pipeline will automate the build and deployment of our application, while the Nexus repository will serve as a centralized location for storing and managing our Docker images.

By following the project, you will have a fully functional website deployment on Kubernetes with a streamlined CI/CD pipeline

## Tools : 
<a href="https://www.jenkins.io" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg" alt="jenkins" width="40" height="40"/> </a> <a href="https://www.docker.com/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="docker" width="40" height="40"/> </a>
<a><img src="https://assets-global.website-files.com/5f10ed4c0ebf7221fb5661a5/5f2af61146c55b6e172fa5b3_NexusRepo_Icon.png" alt="Ansible" width="40" height="40"/> </a>
<a><img src="https://juststickers.in/wp-content/uploads/2018/11/kubernetes-wordmark.png" alt="Ansible" width="40" height="40"/> </a>

## Diagram : 
 <p align="center">
<img  src="https://user-images.githubusercontent.com/69608603/229376532-55c408a4-9d1b-4eed-ade4-d8d201b7ffab.png" alt="centered image" >
</p>
 

## Set the Cluster : 
- #### Prerequisites :
    - Make sure to have Kubectl, and Minikube installed on your local machine 
    - Trust the Nexus Certificate in the Docker installed in your local machine
      ```bash
      sudo mkdir -p /etc/docker/certs.d/nexus:8082
      cp manifests/nexus/registry.crt  /etc/docker/certs.d/nexus:8082/ca.crt
      ```
- #### Create Nexus Repository
     This script will start minikube, and runs all kubernates manifest files to create  Nexus 
  ```bash
   bash nexus.sh
  ```
- #### Add DNS records in the host machine 
     To access Jenkins, and Nexus dashboard from your local browser, in addtion to the deployed website itself, we need to set this records in /etc/hosts
```bash
sudo sh -c "echo '<<minikube ip >> jenkins.dashboard nexus.dashboard goviolin.com  ' >> /etc/hosts"
sudo sh -c "echo ' <<nexus service ip >> nexus'  >> /etc/hosts"
```

- #### Create a minikube tunnel to access the Kubernates cluster from the host machine
```bash
minikube tunnel 
```
- #### Access nexus dashboard from the Host Machine: 
  The URL of Nexus dashboard : https://nexus.dashboard/. <br> 
  To login, you need the password that resides in the nexus pod, you can get it using this command:
  ```bash
  kubectl exec nexus-0 -c nexus -- cat /nexus-data/admin.password
  ```
  change the password and make sure to set the same password in Jenkins Pipline, also enable "Enable anonymous access"

![nexus](https://user-images.githubusercontent.com/69608603/229383371-0d250b7a-b129-486b-9bfc-a2bddfea459e.png)


- #### Create a hosted local Docker repository.
  - Set a name for the reposictory 
  - Configure to use HTTPS with port:8082 .
  - Enable anonymous pull . 
  - In realms,  Enable docker bearer token
- #### Create Jenkins :
     This script will Create the  Jenkins image from the Docker file, push it to Nexus, run the Kubernates manifest files to create Jenkins  
  ```bash
   bash jenkins.sh
  ```
- #### Access jenkins dashboard :
    https://jenkins.dashboard <br>
    Jenkins user : hamdy <br>
    Jenkins pass : VTG266iFe4QfEBYL2eNRHH <br>
    
![jenkins](https://user-images.githubusercontent.com/69608603/229383523-14960241-d636-4e29-bbc2-b7651c9870b0.png)

- #### Run GoViolin Website
```bash
  bash app.sh
```

### Access the Website:
    https://goviolin.com/

![goviolin](https://user-images.githubusercontent.com/69608603/229383473-3d5b955b-6aea-4578-a831-abc2aa47561a.png)






















