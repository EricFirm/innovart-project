resource "aws_iam_role" "innovart-eks-fargate-role" {
    name = "innovart-eks-fargate-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks-fargate-pods.amazonaws.com"
                }
            },
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "innovart-eks-fargate-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
    role = aws_iam_role.innovart-eks-fargate-role.name
}

resource "aws_eks_fargate_profile" "innovart-eks-fargate-profile" {
    cluster_name = aws_eks_cluster.innovart-eks-cluster.name
    fargate_profile_name = "innovart-eks-fargate-profile"
    pod_execution_role_arn = aws_iam_role.innovart-eks-fargate-role.arn

    subnet_ids = concat(
        [data.terraform_remote_state.innovart-vpc.outputs.pub_subnet_id],
        [data.terraform_remote_state.innovart-vpc.outputs.priv_subnet_id]
    )  

    selector {
        namespace = "kube-system"
    }

    selector {
        namespace = "default"

}

 depends_on = [
        aws_iam_role_policy_attachment.innovart-eks-fargate-policy,
    ]

}