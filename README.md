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

From browser you can access jenkins dashboard from :

https://jenkins.dashboard/

Jenkins user : hamdy , jenkins pass : VTG266iFe4QfEBYL2eNRHH

```bash
 cd app/
 docker build -t nexus:8082/goviolin .
 docker push nexus:8082/goviolin

 cd manifests/GoViolin/

 kubectl apply -f . -n app
```
 from browser
 https://goviolin.com/























