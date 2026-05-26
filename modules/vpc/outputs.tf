output "vpc_id" {
  value = aws_vpc.pcs.id
}

output "public_subnet_id" {
  value = aws_subnet.pcs_public.id
}

output "public_sg_id" {
  value = aws_security_group.pcs_public.id
}

output "private_subnet_id" {
  value = aws_subnet.pcs_private.id
}

output "private_sg_id" {
  value = aws_security_group.pcs_private.id
}
