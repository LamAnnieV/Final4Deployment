# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
}
#
#
#
#
#create first instance:default-vpc with jenkins and deadsnakes
resource "aws_instance" "Dep9JenkinsManager" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-0e9087eb7d47d1019"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins-deadsnakes2.sh")}"

  tags = {
    Name : "Dep9JenkinsManager_"
  }
}
#
#
#
#
#create second instance:default-vpc with docker, java environment, and deadsnakes
resource "aws_instance" "Dep9DockerAgent" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-0e9087eb7d47d1019"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("dockeragent2.sh")}"

  tags = {
    Name : "Dep9DockerAgent_"
  }
}
#
#
#
#create third instance:default-vpc with terraform and java environment
resource "aws_instance" "D9EKSAgent" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-0e9087eb7d47d1019"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("eks-jre.sh")}"

  tags = {
    Name : "D9EKSAgent_"
  }
}



output "dep9server1_ip" {
  value = aws_instance.Dep9JenkinsManager.public_ip
}

output "dep9server2_ip" {
  value = aws_instance.Dep9DockerAgent.public_ip
}

output "dep9server3_ip" {
  value = aws_instance.D9EKSAgent.public_ip
}