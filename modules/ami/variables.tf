variable "region" {
  type    = string
}

variable "x86_build_instance" {
  description = "X86 build instance type"
  type = string
  default = "c7a.16xlarge"
}

variable "arm_build_instance" {
  description = "ARM build instance type"
  type = string
  default = "c7g.4xlarge"
}

variable "s3_bucket" {
  description = "S3 bucket that contains the install components"
  type = string
}

variable "image_receipe_version" {
  description = "Image Receipe Version"
  type = string
  default = "1.0.0"
}

variable "ssh_key" {
  description = "SSH key pair to use for instances"
  type = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type = string
}

variable "public_sg_id" {
  description = "Public security group ID"
  type = string
}

variable "slurm_version" {
  description = "Slurm version"
  type = string
}

variable "zfs_filesystem_dns" {
  description = "FSx Lustre filesystem DNS"
  type        = string
}

variable "zfs_filesystem_mnt" {
  description = "FSx Lustre filesystem mount point"
  type        = string
}

variable "ldap_dns" {
  description = "Private DNS address of LDAP server"
  type        = string
}

variable "ldap_password" {
  description = "LDAP bind password"
  type        = string
}
