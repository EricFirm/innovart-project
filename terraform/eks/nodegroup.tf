resource "aws_iam_role" "innovart-eks-nodegroup-role" {
  name = "innovart-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "innovart-eks-nodegroup-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.innovart-eks-nodegroup-role.name
}

resource "aws_iam_role_policy_attachment" "innovart-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.innovart-eks-nodegroup-role.name
}

resource "aws_iam_role_policy_attachment" "innovart-eks-registry-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.innovart-eks-nodegroup-role.name
}

resource "aws_eks_node_group" "innovart-eks-nodegroup" {
  cluster_name    = var.cluster_name
  node_group_name = "innovart-eks-nodegroup"
  node_role_arn   = aws_iam_role.innovart-eks-nodegroup-role.arn
  subnet_ids = concat(
    [data.terraform_remote_state.innovart-vpc.outputs.pub_subnet_id],
    [data.terraform_remote_state.innovart-vpc.outputs.priv_subnet_id]
  )

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  ami_type = "AL2_x86_64"

  disk_size = 5

  depends_on = [
    aws_iam_role_policy_attachment.innovart-eks-nodegroup-policy,
    aws_iam_role_policy_attachment.innovart-eks-cni-policy,
    aws_iam_role_policy_attachment.innovart-eks-registry-policy,
  ]
}
