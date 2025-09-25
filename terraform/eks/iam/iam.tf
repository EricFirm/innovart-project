resource "aws_iam_user" "developer" {
  name = "developer"
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

#data "terraform_remote_state" "innovart_vpc" {
# backend = "s3"
#config = {
# bucket = "innovart-terraform-state"
#key    = "vpc/terraform.tfstate"
#region = "eu-west-1"
#}
#}
