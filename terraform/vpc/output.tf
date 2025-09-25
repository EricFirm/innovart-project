#output "vpc_id" {
# value = aws_vpc.innovart-vpc.id
#}

output "pub_subnet_id" {
  value = aws_subnet.pub-subnet.id
}

output "priv_subnet_id" {
  value = aws_subnet.priv-subnet.id
}
