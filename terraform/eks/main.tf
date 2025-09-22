data "terraform_remote_state" "innovart-vpc" {
    backend = "local"
    config = {
      path = "../vpc/terraform.tfstate"
    }
  
}

resource "aws_iam_role" "innovart-eks-cluster-role" {
    name = "innovart-eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "innovart-eks-cluster-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = "aws_iam_role.innovart-eks-cluster-role"
}

resource "aws_eks_cluster" "innovart-eks-cluster" {
    name     = var.cluster_name
    role_arn = aws_iam_role.innovart-eks-cluster-role.arn

    vpc_config {
        endpoint_private_access = true
        endpoint_public_access  = true
        subnet_ids = concat(
            [data.terraform_remote_state.innovart-vpc.outputs.pub_subnet_id],
            [data.terraform_remote_state.innovart-vpc.outputs.priv_subnet_id]
        )  
    }

    access_config {
      authentication_mode = "API"
      bootstrap_cluster_creator_admin_permissions = true
    }

    bootstrap_self_managed_addons = true
    version = var.eks_version
    upgrade_policy {
      support_type = "STANDARD"
    }

    depends_on = [
        aws_iam_role_policy_attachment.innovart-eks-cluster-policy
    ]
}