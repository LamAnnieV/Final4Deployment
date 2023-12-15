provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-west-1"
}

resource "aws_vpc" "final4_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "final4_vpc"
  }
}

resource "aws_subnet" "publicA" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-west-1a"
  
  tags = {
    "Name" = "public-west-1a"
  }
}

resource "aws_subnet" "privateA" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "us-west-1a"

  tags = {
    "Name" = "private-west-1a"
  }
}


resource "aws_subnet" "publicC" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-west-1c"
  
  tags = {
    "Name" = "public-west-1c"
  }
}

resource "aws_subnet" "privateC" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.80.0/20"
  availability_zone = "us-west-1c"

  tags = {
    "Name" = "private-west-1c"
  }
}

# Create Instance 1
resource "aws_instance" "instanceA" {
  ami                    = "ami-0cbd40f694b804622"
  instance_type          = "t2.medium"
  key_name               = "Fantasic4"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.publicA.id
  vpc_security_group_ids = [aws_security_group.finalsg.id]
  user_data = "${file("docker.sh")}"

  # Define the block device mapping for the EBS volume
  root_block_device {
    volume_size = 16 # Specify the size of the volume in GB
    volume_type = "gp2"
  }  
  
  tags = {
    "Name" : "Final-InstanceA"
  }
}

# Create Instance 2 (Kubernetes Agent)
resource "aws_instance" "instanceC" {
  ami                    = "ami-0cbd40f694b804622"
  instance_type          = "t2.medium"
  key_name               = "Fantasic4"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.publicC.id
  vpc_security_group_ids = [aws_security_group.finalsg.id]
  user_data = "${file("docker.sh")}"
  # Define the block device mapping for the EBS volume
  root_block_device {
    volume_size = 16 # Specify the size of the volume in GB
    volume_type = "gp2"
  }  
    
  tags = {
    "Name" : "Final-InstanceC"
  }
}

resource "aws_route_table_association" "publicA_rt" {
  subnet_id      = aws_subnet.publicA.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "privateA_rt" {
  subnet_id      = aws_subnet.privateA.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "publicC_rt" {
  subnet_id      = aws_subnet.publicC.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "privateC_rt" {
  subnet_id      = aws_subnet.privateC.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "elastic-ip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "final4_igw" {
  vpc_id = aws_vpc.final4_vpc.id
}

resource "aws_nat_gateway" "final4_ngw" {
  subnet_id     = aws_subnet.publicA.id
  allocation_id = aws_eip.elastic-ip.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.final4_vpc.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.final4_vpc.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.final4_igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.final4_ngw.id
}

# Creating Security Group to include ports 22, 8080, 8000 of ingress 
 resource "aws_security_group" "finalsg" {
 name = "Final-Jenkins_SG"
 vpc_id = aws_vpc.final4_vpc.id

 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

 }

  ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
 }

 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
  "Name" : "Final-Jenkins_SG"
  "Terraform" : "true"
 }

}

output "subnet_publicA" {
  value = aws_subnet.publicA.id
}

output "subnet_privateA" {
  value = aws_subnet.privateA.id
}


output "subnet_publicC" {
  value = aws_subnet.publicC.id
}

output "subnet_privateC" {
  value = aws_subnet.privateC.id
}
