module "vpc" {
  source = "./vpc"
}

module "eks" {
  source             = "./eks"
  vpc_id             = var.vpc_id
  vpc_priv_subnet_id = var.vpc_priv_subnet_id
  vpc_pub_subnet_id  = var.vpc_pub_subnet_id
}

#terraform {
# backend "s3" {
#  bucket = "innovart-terraform-state"
# key    = "terraform/terraform.tfstate"
#region = "eu-west-1"
#}
#}

terraform {
  backend "local" {}
}

#data "terraform_remote_state" "innovart_vpc" {
# backend = "s3"
#config = {
# bucket = "innovart-terraform-state"
#key    = "innovart/vpc/terraform.tfstate"
#region = "eu-west-1"
#}
#}



