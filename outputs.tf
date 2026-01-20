output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "ldap_server_private_dns" {
  description = ""
  value = module.ldap.ldap_server_private_dns
}

output fs_openzfs {
  description = "FSx OpenZFS file system ID"
  value = module.fsx.fs_openzfs_id
}

output fs_lustre {
  description = "FSx Lustre file system ID"
  value = module.fsx.fs_lustre_id
}

output "pcs_cluster_id" {
  description = "ID of the Parallel Computing Service cluster"
  value       = module.pcs.pcs_cluster_id
}

output "pcs_cluster_console_url" {
  description = "URL for the Parallel Computing Service console"
  value       = module.pcs.pcs_cluster_console_url
}

output "pcs_ec2_console_url" {
  description = "URL for the EC2 console filtered to PCS login node instances"
  value       = module.pcs.pcs_ec2_console_url
}

