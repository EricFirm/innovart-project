resource "aws_iam_policy" "alb-controller-policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteSecurityGroup",
                "ec2:Describe*",
                "elasticloadbalancing:*",
                "iam:CreateServiceLinkedRole",
                "iam:GetServerCertificate",
                "iam:ListServerCertificates",
                "cognito-idp:DescribeUserPoolClient",
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetWebACL",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        }
    ]       
}
EOF
}

resource "aws_iam_role" "alb-controller-role" {
  name = "alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::504178855667:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/48ABAF74F416B99C4D99A1330D6C4E9E"
        },
        Condition = {
          StringEquals = {
            "oidc.eks.eu-west-1.amazonaws.com/id/48ABAF74F416B99C4D99A1330D6C4E9E:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb-controller-policy-attach" {
  policy_arn = aws_iam_policy.alb-controller-policy.arn
  role       = aws_iam_role.alb-controller-role.name
}
#provider "kubernetes" {
 # host                   = data.aws_eks_cluster.innovart-eks-cluster.endpoint
  #cluster_ca_certificate = base64decode(data.aws_eks_cluster.innovart-eks-cluster.certificate_authority[0].data)
  #token                  = data.aws_eks_cluster_auth.innovart-eks-cluster.token
#} 

resource "kubernetes_service_account" "alb-controller-sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb-controller-role.arn
    }
  }

  depends_on = [
    kubernetes_service_account.alb-controller-sa,
    data.aws_eks_cluster.innovart-eks-cluster
  ]
}




#resource "helm_release" "alb_controller" {
# name       = "aws-load-balancer-controller"
#repository = "https://aws.github.io/eks-charts"
#chart      = "aws-load-balancer-controller"
#namespace  = "kube-system"
#version    = "1.7.2"

#set = [
# {
#  name  = "clusterName"
# value = innovart-eks-cluster
#},
#{
# name  = "serviceAccount.create"
#value = "false"
#},
#{
# name  = "serviceAccount.name"
# value = kubernetes_service_account.alb-controller-sa.metadata[0].name
#},
#{
# name  = "region"
#value = "eu-west-1"
#},
#{
# name  = "vpcId"
#value = data.terraform_remote_state.innovart-vpc.outputs.vpc_id
#}
#]


output "vpc_id" {
  value = module.vpc.vpc_id
}

#output "alb_release_name" {
# value = helm_release.alb_controller.name
#}






