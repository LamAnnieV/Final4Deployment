#!bin/bash
exec > >(tee -a /var/log/user-data.log) 2>&1
echo “Script started at: $(date)”

sudo apt-get update

#install java
sudo apt install -y fontconfig -y openjdk-17-jre

sudo apt update

#download aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt install -y zip

unzip awscliv2.zip

sudo ./aws/install

#aws configure

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
#make executable
chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

#kubectl version --short
#download eks
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
#moving eks cli binary to path 
sudo mv /tmp/eksctl /usr/local/bin

echo “Script completed at: $(date)”