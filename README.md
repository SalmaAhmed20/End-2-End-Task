# End-2-End-Task
End to End Task is a Task that take DevOps Life starting from 
## 1- Automate Creation of EKS Cluster 
that is done using 
### - Terraform Modules (for reusability )
**Module 1:**  terraform create **VPC** 
```
https://github.com/SalmaAhmed20/terraform-aws-vpc.git
```
**Module 2:** terraform create **EKS** depend on **VPC** Module
```
https://github.com/SalmaAhmed20/terraform-aws-eks.git
```
### - Terragrunt (For Keep DRY-ness)
```
https://github.com/SalmaAhmed20/End-2-End-Task/tree/b073b8fcdca34aaaaa888f5d99dd908c28720cb3/terragrunt-aws
```
Terragrunt Code is deployed using [azure-pipelines](https://github.com/SalmaAhmed20/End-2-End-Task/blob/main/CICD/deploy-terragrunt-pipelines.yml)

#### Contains: 3 Stages + Manual Approval 
##### - initalization and check if terraform and terragrunt installed  (terragrunt init)
##### - Plan (terragrunt run-all plan --terragrunt-log-level debug --terragrunt-non-interactive   --terragrunt-ignore-dependency-errors)
##### - Approval 
##### - Apply (terragrunt run-all apply --terragrunt-log-level debug --terragrunt-non-interactive   --auto-approve)

![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/e543db0d-e71b-49d9-9db0-a42911c0c188)
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/be66dc24-254a-45f6-97f7-c76d87ff83f4)
![end2end](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/184523f6-339b-47cb-9e28-c412dab53546)
## 2- Automate Creation of Secret Management tool (*vault*)
### Note [prerequisite.sh](https://github.com/SalmaAhmed20/End-2-End-Task/blob/b073b8fcdca34aaaaa888f5d99dd908c28720cb3/terraform-vault-deploy/prerequisite.sh)
#### 1st You need to create EC2 instance (bastion host) at same VPC of cluster to access eks cluster
#### 2nd install awscliv2 , kubectl , eksctl on bastion host 
```bash
sudo apt-get update
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install -i /usr/bin/aws-cli -b /usr/bin/ --update
rm awscliv2.zip
rm -R ./aws
```
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```
#### 3rd Config your bastion host 
```
aws config
aws eks update-kubeconfig --region eu-west-1 --name $(CLUSTER_NAME)
```
#### 4th enable eks-addons to dynamically create ebs volume 
```
eksctl delete iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster test
eksctl utils associate-iam-oidc-provider --region=$REGION --cluster=test --approve
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster test --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve \
    --role-only \
    --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster test \
    --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole
```
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/07cb728a-8e52-4a50-94f7-e9fce937ae27)

#### 5th Register bastion Host as agent at pool to be used at execute pipeline 
```
curl -LO https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz
mkdir myagent && cd myagent
tar zxvf ~/vsts-agent-linux-x64-3.225.0.tar.gz
```
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/eb482139-90af-494a-9ebb-06a23e6b0515)

#### 6th Run Pipeline [deploy-vault.yaml](https://github.com/SalmaAhmed20/End-2-End-Task/blob/b073b8fcdca34aaaaa888f5d99dd908c28720cb3/CICD/deploy-vault.yml)
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/b140603e-c614-4014-bed3-4567a33b321a)


#### (Optional) You can expose vault-ui using loadbalancer [ui-service.yaml](https://github.com/SalmaAhmed20/End-2-End-Task/blob/main/terraform-vault-deploy/ui-service.yaml)
```
kubectl apply -f terraform-vault-deploy/
```
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/96c98a2a-425b-4c6e-9be3-1ced97669d36)
![image](https://github.com/SalmaAhmed20/End-2-End-Task/assets/64385957/e4f01b74-75a8-4ff3-9525-2d3871f1ffdd)

 then Run Commands inside [afterdeploy.sh](https://github.com/SalmaAhmed20/End-2-End-Task/blob/main/terraform-vault-deploy/afterdeploy.sh) to \
 1- initalize vault (get keyshares and root token)\
 2- Unseal vaul to can store new secrets\
 ## 3- Create Private ECR repo to push docker image created on it
 you can find the application and it's dockerfile at [application](https://github.com/SalmaAhmed20/End-2-End-Task/tree/main/application)
 
 
