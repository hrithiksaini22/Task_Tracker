Checkout the youtube videos for reference-
1) Deploy EC2, ECR, and other AWS resources using Terraform-  https://www.youtube.com/watch?v=7lJGdpRzcPY
2) Deploy the App using ArgoCD and EKS- https://www.youtube.com/watch?v=o8apDmWGo8s

## Installation on EC2 Instance
Install Jenkins, configure Docker as agent, set up cicd, deploy applications to k8s and much more.

## AWS EC2 Instance

- Go to AWS Console
- Instances(running)
- Launch instances

<img width="994" alt="Screenshot 2023-02-01 at 12 37 45 PM" src="https://user-images.githubusercontent.com/43399466/215974891-196abfe9-ace0-407b-abd2-adcffe218e3f.png">

### Install Jenkins.

Pre-Requisites:
 - Java (JDK)

### Run the below commands to install Java and Jenkins

Install Java

```
sudo apt update
sudo apt install openjdk-17-jre
```

Verify Java is Installed

```
java -version
```

Now, you can proceed with installing Jenkins

```
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```

**Note: ** By default, Jenkins will not be accessible to the external world due to the inbound traffic restriction by AWS. Open port 8080 in the inbound traffic rules as show below.

- EC2 > Instances > Click on <Instance-ID>
- In the bottom tabs -> Click on Security
- Security groups
- Add inbound traffic rules as shown in the image (you can just allow TCP 8080 as well, in my case, I allowed `All traffic`).

<img width="1187" alt="Screenshot 2023-02-01 at 12 42 01 PM" src="https://user-images.githubusercontent.com/43399466/215975712-2fc569cb-9d76-49b4-9345-d8b62187aa22.png">


### Login to Jenkins using the below URL:

http://<ec2-instance-public-ip-address>:8080    [You can get the ec2-instance-public-ip-address from your AWS EC2 console page]

Note: If you are not interested in allowing `All Traffic` to your EC2 instance
      1. Delete the inbound traffic rule for your instance
      2. Edit the inbound traffic rule to only allow custom TCP port `8080`
  
After you login to Jenkins, 
      - Run the command to copy the Jenkins Admin Password - `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
      - Enter the Administrator password
      
<img width="1291" alt="Screenshot 2023-02-01 at 10 56 25 AM" src="https://user-images.githubusercontent.com/43399466/215959008-3ebca431-1f14-4d81-9f12-6bb232bfbee3.png">

### Click on Install suggested plugins

<img width="1291" alt="Screenshot 2023-02-01 at 10 58 40 AM" src="https://user-images.githubusercontent.com/43399466/215959294-047eadef-7e64-4795-bd3b-b1efb0375988.png">

Wait for the Jenkins to Install suggested plugins

<img width="1291" alt="Screenshot 2023-02-01 at 10 59 31 AM" src="https://user-images.githubusercontent.com/43399466/215959398-344b5721-28ec-47a5-8908-b698e435608d.png">

Create First Admin User or Skip the step [If you want to use this Jenkins instance for future use-cases as well, better to create admin user]

<img width="990" alt="Screenshot 2023-02-01 at 11 02 09 AM" src="https://user-images.githubusercontent.com/43399466/215959757-403246c8-e739-4103-9265-6bdab418013e.png">

Jenkins Installation is Successful. You can now starting using the Jenkins 

<img width="990" alt="Screenshot 2023-02-01 at 11 14 13 AM" src="https://user-images.githubusercontent.com/43399466/215961440-3f13f82b-61a2-4117-88bc-0da265a67fa7.png">

## Install the Docker Pipeline plugin in Jenkins:

   - Log in to Jenkins.
   - Go to Manage Jenkins > Manage Plugins.
   - In the Available tab, search for "Docker Pipeline".
   - Select the plugin and click the Install button.
   - Restart Jenkins after the plugin is installed.
   
<img width="1392" alt="Screenshot 2023-02-01 at 12 17 02 PM" src="https://user-images.githubusercontent.com/43399466/215973898-7c366525-15db-4876-bd71-49522ecb267d.png">

Wait for the Jenkins to be restarted.


## Docker Slave Configuration

Run the below command to Install Docker

```
sudo apt update
sudo apt install docker.io
```
 
### Grant Jenkins user and Ubuntu user permission to docker deamon.

```
sudo su - 
usermod -aG docker jenkins
usermod -aG docker ubuntu
systemctl restart docker
```

Once you are done with the above steps, it is better to restart Jenkins.

```
http://<ec2-instance-public-ip>:8080/restart
```

The docker agent configuration is now successful.

### build a jenkins pipeline

![image](https://github.com/user-attachments/assets/40d891eb-b1e7-4288-bd97-bb8742b6a080)

2. Configure Source Code Management (SCM)
To link Jenkins to your Git repository (e.g., GitHub, GitLab, Bitbucket), configure the SCM settings in the Jenkins job.

Step 2.1: Select Source Code Management

Inside the created Jenkins job, go to the Pipeline section and look for Source Code Management.
Choose Git as the SCM option.
Step 2.2: Enter Repository Details

Enter the URL of your Git repository (e.g., https://github.com/your-username/your-repo.git).
If your repository is private, you’ll need to provide authentication credentials:
Username/Password or Personal Access Token for GitHub.
Click Add under Credentials to store your Git credentials securely.
Step 2.3: Configure Branch

In the Branch Specifier field, specify the branch you want to use for the pipeline (e.g., */main or */master).
![image](https://github.com/user-attachments/assets/77e5b49b-4019-4887-9b28-a3666c7d188b)
![image](https://github.com/user-attachments/assets/b792e434-2eb1-46f9-9c34-d1257f81c93d)

Step 2.3: Now run the pipeline-
![image](https://github.com/user-attachments/assets/5cf50e07-07e9-4ed3-8914-4a24bddc8d99)

![image](https://github.com/user-attachments/assets/4439114d-e491-4a46-bdbb-31a881793aad)

Updated deployment.yaml file through our pipeline
![image](https://github.com/user-attachments/assets/6301b43e-20a0-48d5-966e-ca1c1a37ee65)


### Continuos Deployment
Now we would be deploying a new Ubuntu EC2 instance which would be used to deploy our EKS cluster and interact with it-

1. Install AWS CLI
To interact with AWS services, we need to install AWS CLI version 2.

Download the AWS CLI version 2 installer:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

Install the unzip tool (if not already installed):
sudo apt install unzip

Unzip the AWS CLI installer:
sudo unzip awscliv2.zip

Install AWS CLI:
sudo ./aws/install

Verify AWS CLI installation:
aws --version

2. Install eksctl
eksctl is a tool for creating and managing EKS clusters.

Download and install eksctl:
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

Move eksctl to /usr/local/bin:
sudo mv /tmp/eksctl /usr/local/bin

Verify eksctl installation:
eksctl version

3. Install kubectl
kubectl is a command-line tool to interact with Kubernetes clusters.

Download kubectl:
sudo curl --silent --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl

Make kubectl executable:
sudo chmod +x /usr/local/bin/kubectl

Verify kubectl installation:
kubectl version --short --client

4. Deploy EKS Cluster
Use eksctl to create and manage an EKS cluster in AWS.

Create an EKS cluster:
eksctl create cluster --name demo-eks --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --managed --nodes 2

Verify the EKS cluster status:
eksctl get cluster --name demo-eks --region us-east-1

Update kubeconfig to interact with the EKS cluster:
aws eks --region us-east-1 update-kubeconfig --name demo-eks

![image](https://github.com/user-attachments/assets/d4ba86c5-412e-4491-8d7c-e61664f7ce28)


5. Install ArgoCD on EKS Cluster
ArgoCD is a GitOps continuous delivery tool for Kubernetes.

Create the argocd namespace:
kubectl create namespace argocd

Install ArgoCD by applying the official ArgoCD manifest:
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Expose the ArgoCD server by modifying the service type to LoadBalancer:
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

Retrieve the initial admin password for ArgoCD:
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

### Access ArgoCD and configure with our github repository 

Step 1: Access ArgoCD UI via Load Balancer
![image](https://github.com/user-attachments/assets/fa729ea2-c4e7-4fb7-8dc2-1a3c0d1e517e)

Obtain the Load Balancer DNS name:

From the AWS Load Balancer details page, copy the DNS name. Example:
accc5153de474fafcb33569c0c833299-976374730.us-east-1.elb.amazonaws.com.
Access ArgoCD UI in a browser:

Open your browser and navigate to the Load Balancer URL:
http://accc5153de474fafcb33569c0c833299-976374730.us-east-1.elb.amazonaws.com.
Login to ArgoCD:

![image](https://github.com/user-attachments/assets/5e7341fa-4340-4f61-b2a9-e358d36c5d43)

Use the admin username and the initial password fetched from the secret:
sql
Copy code
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
Step 2: Create a New Application in ArgoCD
In the ArgoCD UI:

Click on + New App.
Fill in Application Details:

Application Name: task-tracker-app
Project: default
Source:
Repo URL: https://github.com/hrithiksaini22/Task_Tracker.git
Path: k8s-manifests/
Target Revision: HEAD
Destination:
Cluster URL: https://kubernetes.default.svc
Namespace: vc
Sync Policy:
Automated Sync: Enable automated sync with no manual intervention.
Create the Application:

Click Create.

![image](https://github.com/user-attachments/assets/c74b97d6-80b8-4cf7-905c-3b09f2e4777d)

Step 3: Sync the Application
Sync the Application in ArgoCD:
After creating the application, click on Sync and then confirm by clicking Sync again to deploy.

![image](https://github.com/user-attachments/assets/dbdc2079-6a3c-479c-87a2-91315f57bd8e)

Step 4: Verify the Deployment
Check Application Status:

Monitor the sync status and ensure the application status shows as Healthy and Synced.

![image](https://github.com/user-attachments/assets/e9c90277-ed97-42c4-875f-b63c7f62d64d)

Access the Application:

If your application exposes a service, access it via the Load Balancer with the respective port. 
![image](https://github.com/user-attachments/assets/989c7bd9-972b-4ac6-849e-1829fb2d6325)

![image](https://github.com/user-attachments/assets/20a06128-b3ef-4909-a29d-af58469c4873)

### Installation of Prometheus and Grafana
Pre-requisites:
1) EKS Cluster needs to be up and running. 
2) Install Helm3 on the EC2 used to access EKS cluster.
3) EC2 instance to access EKS cluster

### Helm 3 can be installed many ways. We will install Helm 3 using scripts option.

Download scripts 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

provide permission
sudo chmod 700 get_helm.sh

Execute script to install
sudo ./get_helm.sh

Verify installation
helm version --client

Now 

Implementation steps
We need to add the Helm Stable Charts for your EC2. Execute the below command:

helm repo add stable https://charts.helm.sh/stable

![image](https://github.com/user-attachments/assets/aa1ecf8e-718c-40e4-b7ac-bb86ed282fc4)


# Add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

![image](https://github.com/user-attachments/assets/93cab33a-36a0-4b1d-9cf2-8390ac766f2c)


helm search repo prometheus-community

Prometheus and grafana helm chart moved to kube prometheus stack

![image](https://github.com/user-attachments/assets/9185bb36-b409-4c2e-8080-1ac13539a591)

Create Prometheus namespace
kubectl create namespace prometheus
![image](https://github.com/user-attachments/assets/72e736d4-74ff-448c-b132-277c5ce1fc08)


Install kube-prometheus-stack

Below is helm command to install kube-prometheus-stack. The helm repo kube-stack-prometheus (formerly prometheus-operator) comes with a grafana deployment embedded.

helm install stable prometheus-community/kube-prometheus-stack -n prometheus

![image](https://github.com/user-attachments/assets/69f768a1-cf60-4915-87a8-5ae684921560)

Lets check if prometheus and grafana pods are running already
kubectl get pods -n prometheus

![image](https://github.com/user-attachments/assets/8bfb9cea-ca19-4bdb-b239-3ae1ed5b0479)


kubectl get svc -n prometheus

![image](https://github.com/user-attachments/assets/a974ba10-fd99-4ef6-85d0-a560d8a3722c)


This confirms that prometheus and grafana have been installed successfully using Helm.

In order to make prometheus and grafana available outside the cluster, use LoadBalancer or NodePort instead of ClusterIP.
Edit Prometheus Service

![image](https://github.com/user-attachments/assets/3a96e31b-74fc-443c-9d22-d15d6310ddff)

kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus


Edit Grafana Service
kubectl edit svc stable-grafana -n prometheus
![image](https://github.com/user-attachments/assets/ebd3da1d-d1cb-47bc-a8f6-98984463da9f)


Verify if service is changed to LoadBalancer and also to get the Load Balancer URL.

kubectl get svc -n prometheus



Access Grafana UI in the browser

Get the URL from the above screenshot and put in the browser

![image](https://github.com/user-attachments/assets/24f97c5b-1cc9-4955-a685-aba769ce5966)


UserName: admin 
Password: prom-operator

Create Dashboard in Grafana

In Grafana, we can create various kinds of dashboards as per our needs.
How to Create Kubernetes Monitoring Dashboard?
For creating a dashboard to monitor the cluster:



Click '+' button on left panel and select ‘Import’.

Enter 12740 dashboard id under Grafana.com Dashboard.

Click ‘Load’.

Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.

Click ‘Import’.



This will show monitoring dashboard for all cluster nodes


![image](https://github.com/user-attachments/assets/a8918a69-cc6c-44aa-86db-b09536310e4f)


![image](https://github.com/user-attachments/assets/af80ccd3-08ad-447c-928d-d8cdd2708a57)


![image](https://github.com/user-attachments/assets/9655db93-e692-458f-8a9e-5dbe07697b8b)


How to Create Kubernetes Cluster Monitoring Dashboard?


For creating a dashboard to monitor the cluster:



Click '+' button on left panel and select ‘Import’.

Enter 3119 dashboard id under Grafana.com Dashboard.

Click ‘Load’.

Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.

Click ‘Import’.

This will show monitoring dashboard for all cluster nodes

![image](https://github.com/user-attachments/assets/b12b65d0-3460-41c5-bfff-1ee2f61739c7)

Create POD Monitoring Dashboard
For creating a dashboard to monitor the cluster:



Click '+' button on left panel and select ‘Import’.

Enter 6417 dashboard id under Grafana.com Dashboard.

Click ‘Load’.

Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.

Click ‘Import’.

![image](https://github.com/user-attachments/assets/1721bb2f-58b0-4f34-be05-2280a25600c5)


![image](https://github.com/user-attachments/assets/4cc96935-c181-4c80-b21d-adbbd82a5af6)



This will show monitoring dashboard for all cluster nodes.


![image](https://github.com/user-attachments/assets/07950655-68ad-4428-9cb0-cd083b81a58f)



Cleanup EKS Cluster
Use the below command to delete EKS cluster to avoid being charged by AWS.
eksctl delete cluster --name demo-eks --region us-east-1

or Login to AWS console --> AWS Cloud formation --> delete the stack manually.

you can also delete the cluster under AWS console --> Elastic Kubernetes Service --> Clusters
Click on Delete cluster


