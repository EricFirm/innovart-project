terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "eu-west-1"
}

provider "helm" {
}

data "aws_eks_cluster" "innovart-eks-cluster" {
  name = "innovart-eks-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.innovart-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.innovart-eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.innovart-eks-cluster.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.innovart-eks-cluster.name]
  }
}


#resource "aws_eks_cluster" "innovart-eks-cluster" {
 # name     = "innovart-eks-cluster"
  #role_arn = data.aws_iam_role.innovart-eks-cluster-role.arn
  #version  = "1.32"

  #vpc_config {
    #endpoint_private_access = true
    #endpoint_public_access  = true
    #subnet_ids = concat(
     # [var.vpc_pub_subnet_id],
      #[var.vpc_priv_subnet_id]
    #)
  #}
#}

data "aws_eks_cluster_auth" "innovart-eks-cluster" {
  name = data.aws_eks_cluster.innovart-eks-cluster.name
}

#resource "aws_iam_role" "innovart-eks-cluster-role" {
 # name = "innovart-eks-cluster-role"
  #assume_role_policy = jsonencode({
   # Version = "2012-10-17"
    #Statement = [
     # {
      #  Action = "sts:AssumeRole"
       # Effect = "Allow"
        #Principal = {
         # Service = "eks.amazonaws.com"
        #}
     # },
    #]
  #})
#}

data "aws_iam_role" "innovart-eks-cluster-role" {
  name = "innovart-eks-cluster-role"
}

data "aws_caller_identity" "current" {}


