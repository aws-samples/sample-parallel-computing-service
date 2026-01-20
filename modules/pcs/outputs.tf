output "pcs_cluster_id" {
  description = "ID of the AWS Parallel Computing Service cluster"
  value       = awscc_pcs_cluster.wx.cluster_id
}

output "pcs_cluster_status" {
  description = "Status of the AWS Parallel Computing Service cluster"
  value       = awscc_pcs_cluster.wx.status
}

output "pcs_cluster_console_url" {
  description = "URL for the AWS Parallel Computing Service console"
  value       = "https://console.aws.amazon.com/pcs/home?region=${var.region}#/clusters/${awscc_pcs_cluster.wx.cluster_id}"
}

output "pcs_ec2_console_url" {
  description = "URL for the EC2 console filtered to PCS login node instances"
  value       = "https://console.aws.amazon.com/ec2/home?region=${var.region}#Instances:instanceState=running;tag:aws:pcs:compute-node-group-id=${awscc_pcs_compute_node_group.login.compute_node_group_id}"
}

output "instance_nics" {
  value = local.nics
}

