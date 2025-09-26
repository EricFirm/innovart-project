resource "aws_iam_user" "developer" {
  name = "developer"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "developer-console" {
  user    = aws_iam_user.developer.name
  password_reset_required = true
  password_length = 16
}

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

resource "aws_iam_role" "developer-role" {
  name = "developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.developer.arn
        }
      }
    ]
  })

}

resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.developer-role.arn
        username = "developer"
        groups   = ["developer-group"]
      }
    ])
  }
}

resource "kubernetes_cluster_role" "kubernetes_readonly" {
  metadata {
    name = "kubernetes-readonly"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "developer-binding" {
  metadata {
    name = "developer-readonly-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubernetes_readonly.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "developer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

data "aws_eks_cluster" "innovart-eks-cluster" {
  name = "innovart-eks-cluster"
}

data "aws_eks_cluster_auth" "innovart-eks-cluster" {
  name = data.aws_eks_cluster.innovart-eks-cluster.name
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

data "aws_caller_identity" "current" {}

output "aws_console_signin_url" {
  value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}

#data "terraform_remote_state" "innovart_vpc" {
# backend = "s3"
#config = {
# bucket = "innovart-terraform-state"
#key    = "vpc/terraform.tfstate"
#region = "eu-west-1"
#}
#}
