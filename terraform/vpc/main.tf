#data "terraform_remote_state" "innovart_vpc" {
 # backend = "s3"
  #config = {
   # bucket = "innovart-terraform-state"
    #key    = "vpc/terraform.tfstate"
    #region = "eu-west-1"
  #}
#}

resource "aws_vpc" "innovart-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

output "vpc_id" {
  value = aws_vpc.innovart-vpc.id
  
}

locals {
  vpc_tags = {
  "kubernetes.io/cluster/innovart-vpc" = "owned" }
}


resource "aws_subnet" "priv-subnet" {
  vpc_id                  = aws_vpc.innovart-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = local.vpc_tags
}


resource "aws_subnet" "pub-subnet" {
  vpc_id                  = aws_vpc.innovart-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = local.vpc_tags
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.innovart-vpc.id
}

resource "aws_eip" "nat-eip" {
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.pub-subnet.id
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.innovart-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "innovart-route-table"
  }
}

resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.innovart-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id

  }
}

resource "aws_route_table_association" "pub-subnet-assoc" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
}
resource "aws_route_table_association" "priv-subnet-assoc" {
  subnet_id      = aws_subnet.priv-subnet.id
  route_table_id = aws_route_table.priv-rt.id
}

resource "aws_security_group" "innovart-sg" {
  name        = "innovart-sg"
  description = "Security group for Innovart VPC"
  vpc_id      = aws_vpc.innovart-vpc.id

  ingress {
    description = "Allow TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
