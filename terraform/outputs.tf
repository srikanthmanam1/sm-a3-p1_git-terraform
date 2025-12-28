#------------------------------------------------------------
# outputs.tf
#------------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.sm-std-vpc1.id
}

output "public_subnets" {
  value = aws_subnet.sm-std-pub-sn1[*].id
}

output "private_subnets" {
  value = aws_subnet.sm-std-pvt-sn1[*].id
}

output "security_group_id" {
  value = aws_security_group.sm-std-sg1.id
}

output "no_av_zn" {
  value = local.no_av_zn
}













