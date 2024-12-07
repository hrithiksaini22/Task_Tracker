Checkout the youtube videos for reference-
1) 
2)

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

