
data "aws_ami" "al2023_x86" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.12*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["137112412989"] # AWS
}

resource "random_password" "ldap_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "ldap_password" {
  name                           = "ldap_password"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "ldap_password" {
  secret_id     = aws_secretsmanager_secret.ldap_password.id
  secret_string = random_password.ldap_password.result
}

data "local_file" "users_ldif" {
  filename = var.users_ldif
}

locals {
  user_data = templatefile("${path.module}/ldap.tftpl", {
    region = var.region,
    ldap_password = aws_secretsmanager_secret_version.ldap_password.secret_string,
    users_ldif = data.local_file.users_ldif.content
  })
}

resource "aws_instance" "ldap" {
  ami                    = data.aws_ami.al2023_x86.id
  instance_type          = var.ldap_instance
  vpc_security_group_ids = [var.private_sg_id]
  subnet_id              = var.private_subnet_id
  key_name               = var.ssh_key
  user_data              = local.user_data
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 20
    volume_type           = "gp3"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  tags = {
    Name = "LDAP Server"
  }
}

