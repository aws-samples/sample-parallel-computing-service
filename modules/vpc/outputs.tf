output "vpc_id" {
  value = aws_vpc.wx.id
}

output "public_subnet_id" {
  value = aws_subnet.wx_public.id
}

output "public_sg_id" {
  value = aws_security_group.wx_public.id
}

output "private_subnet_id" {
  value = aws_subnet.wx_private.id
}

output "private_sg_id" {
  value = aws_security_group.wx_private.id
}
