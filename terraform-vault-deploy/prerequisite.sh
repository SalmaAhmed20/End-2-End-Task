# Need awscli2 "version 2"
#!/bin/bash
sudo apt-get update
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install -i /usr/bin/aws-cli -b /usr/bin/ --update
rm awscliv2.zip
rm -R ./aws
# aws config
touch ~/.aws/credentials ~/.aws/config
echo [default] > ~/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
echo [default] > ~/.aws/config
echo "region = $REGION" >>~/.aws/config
#  Need Kubectl tool

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Need eksctl tool
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# add cluster to kubeconfig
aws eks update-kubeconfig --region $REGION --name test

# Adds On "CSI EBS Driver"
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

