variable "vpc_pub_subnet_id" {
  description = "The VPC Public Subnet ID"
  type        = string
}

variable "vpc_priv_subnet_id" {
  description = "The VPC Private Subnet ID"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-1"
}
