
output "ldap_server_private_dns" {
  value = aws_instance.ldap.private_dns
}

output "ldap_server_instance_id" {
  value = aws_instance.ldap.id
}

output "ldap_password" {
  value = aws_secretsmanager_secret_version.ldap_password.secret_string
  sensitive = true
}
