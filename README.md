minikube start

# creating nexus repository manager statefulset
cd manifests/nexus/
kubectl apply -f .

# watch the pod until it become up and running
watch kubectl  get pods

# add nexus HTTPS certificate to minikube
minikube ssh 'sudo mkdir /etc/docker/certs.d/nexus:8082'
minikube cp registry.crt /etc/docker/certs.d/nexus:8082/ca.crt
minikube ssh 'ls  /etc/docker/certs.d/nexus:8082/ca.crt'

# add DNS resolutio names in the host in order to access from the browser
sudo sh -c "echo '<<minikube ip >> jenkins.dashboard nexus.dashboard goviolin.com  ' >> /etc/hosts"
sudo sh -c "echo ' <<nexus service ip >> nexus'  >> /etc/hosts"

# create ingress rules to access nexus and jenkins using HTTPS through NGINX
cd manifests/ingress/
kubectl apply -f  .

# enable NGIX controller
minikube addons enable ingress

# create a minikube tunnel to access the cluster
minikube tunnel

# from the host machine open descires browser and access nexus
in browser type :  https://nexus.dashboard/


To login you need the password in nexus pod : kubectl exec nexus-0 -c nexus -- cat /nexus-data/admin.password

change password to admin admin , Enable anonymous access

create a hosted docker hosted in https port 8082 , enable anonymous pull , in realms  enable docker bearer token

# create the Jenkins image and push it in nexus
cd JenkinsImage/

docker build -t nexus:8082/jenkins:latest .

docker login nexus:8082 -u admin -p admin

docker push nexus:8082/jenkins:latest

cd manifests/jenkins

kubectl apply -f .

# check that jenkins pod are working
kubectl  get pods

From browser you can access jenkins dashboard from :

https://jenkins.dashboard/

Jenkins user : hamdy , jenkins pass : VTG266iFe4QfEBYL2eNRHH


 cd app/
 docker build -t nexus:8082/goviolin .
 docker push nexus:8082/goviolin

 cd manifests/GoViolin/

 kubectl apply -f . -n app

 from browser
 https://goviolin.com/























