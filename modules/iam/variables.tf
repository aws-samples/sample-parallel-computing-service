variable "project" {
  type        = string
  description = "The project name."
  default     = null
}

variable "ssh_key" {
  description = "ssh public key for PCS"
  type        = string
  default     = null
}

