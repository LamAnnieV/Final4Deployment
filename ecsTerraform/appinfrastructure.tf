provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
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
  availability_zone = "us-east-1a"
  
  tags = {
    "Name" = "public-east-1a"
  }
}

resource "aws_subnet" "privateA" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private-east-1a"
  }
}

resource "aws_subnet" "publicB" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "public-east-1b"
  }
}

resource "aws_subnet" "privateB" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.64.0/20"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "private-east-1b"
  }
}

resource "aws_subnet" "publicC" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-east-1c"
  
  tags = {
    "Name" = "public-east-1c"
  }
}

resource "aws_subnet" "privateC" {
  vpc_id            = aws_vpc.final4_vpc.id
  cidr_block        = "10.0.80.0/20"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "private-east-1c"
  }
}
output "subnet_publicA" {
  value = aws_subnet.publicA.id
}

output "subnet_privateA" {
  value = aws_subnet.privateA.id
}

output "subnet_publicB" {
  value = aws_subnet.publicB.id
}

output "subnet_privateB" {
  value =aws_subnet.privateB.id
}

output "subnet_publicC" {
  value = aws_subnet.publicC.id
}

output "subnet_privateC" {
  value = aws_subnet.privateC.id
}

resource "aws_route_table_association" "publicA_rt" {
  subnet_id      = aws_subnet.publicA.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "privateA_rt" {
  subnet_id      = aws_subnet.privateA.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "publicB_rt" {
  subnet_id      = aws_subnet.publicB.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "privateB_rt" {
  subnet_id      = aws_subnet.privateB.id
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
