output "pcs_compute_role_name" {
  description = "Name of the IAM instance role"
  value       = aws_iam_role.pcs_compute_role.name
}

output "pcs_compute_role_arn" {
  description = "ARN of the IAM instance role"
  value       = aws_iam_role.pcs_compute_role.arn
}

output "pcs_compute_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.pcs_compute_profile.name
}

output "pcs_compute_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.pcs_compute_profile.arn
}

output "pcs_compute_profile_id" {
  description = "ID of the IAM PCS compute profile"
  value       = aws_iam_instance_profile.pcs_compute_profile.id
}

output "ssh_key" {
  description = "SSH key pair name"
  value = aws_key_pair.pcs.key_name
}
