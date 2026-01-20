variable "region" {
  type    = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type = string
}

variable "public_sg_id" {
  description = "Public security group ID"
  type = string
}

variable "private_subnet_id" {
  description = "Private subnet ID"
  type = string
}

variable "private_sg_ids" {
  description = "Private security group IDs"
  type = list
}

variable "ssh_key" {
  description = "SSH key pair to use for instances"
  type = string
}

variable "slurm_version" {
  description = "Slurm version"
  type = string
}

variable "pcs_compute_profile_arn" {
  description = "ARN of the PCS compute profile to attach to instances"
  type = string
}

variable "ami_id_x86" {
  description = "The AMI ID of the PCS X86_64 instance"
  type = string
}

variable "ami_id_arm" {
  description = "The AMI ID of the PCS ARM64 instance"
  type = string
}

variable "instance_login" {
  description = "Instance type of login node(s)"
  type        = string
}

variable "instance_x86" {
  description = "Instance type of CPU X86_64 node(s)"
  type        = list
}

variable "instance_arm" {
  description = "Instance type of CPU ARM64 node(s)"
  type        = list
}

variable "instance_gpu" {
  description = "Instance type of GPU node(s)"
  type        = list
}

variable "zfs_filesystem_dns" {
  description = "FSx Lustre filesystem DNS"
  type        = string
}

variable "zfs_filesystem_mnt" {
  description = "FSx Lustre filesystem mount point"
  type        = string
}

variable "lustre_filesystem_dns" {
  description = "FSx Lustre filesystem DNS"
  type        = string
}

variable "lustre_filesystem_mnt" {
  description = "FSx Lustre filesystem mount point"
  type        = string
}

variable "tags" {
  description = "Tags to add to infrastructure"
  type        = map(string)
  default     = {}
}
