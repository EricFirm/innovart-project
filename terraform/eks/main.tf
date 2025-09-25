

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

resource "aws_iam_policy" "innovart-eks-cluster-policy" {
  name        = "innovart-eks-cluster-policy"
  description = "Policy for EKS Cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "eks:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "innovart-eks-cluster-policy" {
  policy_arn = aws_iam_policy.innovart-eks-cluster-policy.arn
  role       = aws_iam_role.innovart-eks-cluster-role.name
}

#resource "aws_eks_cluster" "innovart-eks-cluster" {
 # name     = "innovart-eks-cluster"
  #role_arn = aws_iam_role.innovart-eks-cluster-role.arn
  #version  = "1.32"

data "aws_eks_cluster" "innovart-eks-cluster" {
  name = "innovart-eks-cluster"
}

 # vpc_config {
  #  endpoint_private_access = true
   # endpoint_public_access  = true
    #subnet_ids = concat(
     # [var.vpc_pub_subnet_id],
      #[var.vpc_priv_subnet_id]
    #)
  #}

  #access_config {
   # authentication_mode                         = "API"
    #bootstrap_cluster_creator_admin_permissions = true
  #}

  #upgrade_policy {
   # support_type = "STANDARD"
  #}

 # depends_on = [
  #  aws_iam_role_policy_attachment.innovart-eks-cluster-policy
  #]
#}

data "aws_eks_cluster_auth" "innovart-eks-cluster" {
  name = data.aws_eks_cluster.innovart-eks-cluster.name
}

output "cluster_endpoint" {
  value = data.aws_eks_cluster.innovart-eks-cluster.endpoint
}

output "cluster_certificate_authority" {
  value = data.aws_eks_cluster.innovart-eks-cluster.certificate_authority[0].data
}

output "cluster_name" {
  value = data.aws_eks_cluster.innovart-eks-cluster.name
}
