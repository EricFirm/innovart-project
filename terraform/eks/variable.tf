variable "eks_version" {
  description = "The EKS version"
  type        = string
  default     = "1.32"
}

variable "cluster_name" {
  description = "The EKS cluster Name"
  type        = string
  default     = "innovart-eks-cluster"
}
