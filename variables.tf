
variable "profile" {
  type        = string
  description = "The AWS profile used to deploy the clusters."
  default     = null
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "availability_zone" {
  type    = string
  default = "us-east-2b"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "private_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "slurm_version" {
  description = "Slurm version"
  type = string
  default = "25.05"
}

variable "instance_login" {
  description = "Instance type of login node(s)"
  type        = string
  default     = "c6a.8xlarge"
}

variable "instance_gpu" {
  description = "Instance type of GPU node(s)"
  type        = list
  default     = ["p5e.48xlarge"]
}

variable "capacity_block" {
  description = "ML Capacity block ID"
  type = string
  default = null
}

variable "ssh_key" {
  description = "ssh public key for instances"
  type = string
  default = null
}

variable "s3_bucket" {
  description = "S3 bucket name"
  type = string
  default = null
}

variable "users" {
  description = "A LDIF file containing users of the cluster"
  type = string
  default = null
}
