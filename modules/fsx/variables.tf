variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_cidr" {
  type = string
}

variable "private_cidr" {
  type = string
}


variable "fsxl" {
  type = object({
    deployment_type       = string
    data_compression_type = string
    efa_enabled           = bool
    storage_type          = string
    throughput_capacity   = number
    data_read_cache = object({
      sizing_mode = string
      size        = number
    })
    metadata = object({
      iops = number
      mode = string
    })
  })
  default = {
    deployment_type       = "PERSISTENT_2"
    data_compression_type = "LZ4"
    efa_enabled           = true
    storage_type          = "INTELLIGENT_TIERING"
    throughput_capacity   = 4000
    data_read_cache = {
      sizing_mode = "USER_PROVISIONED"
      size        = 20000
    }
    metadata = {
      iops = 6000
      mode = "USER_PROVISIONED"
    }
  }
}

variable "fsxz" {
  type = object({
    storage_capacity      = number
    deployment_type       = string
    throughput_capacity   = number
    data_compression_type = string
    nfs_options           = list(string)
    volume_nfs_options    = list(string)
  })
  default = {
    storage_capacity      = 1024
    deployment_type       = "SINGLE_AZ_HA_2"
    throughput_capacity   = 2560
    data_compression_type = "ZSTD"
    nfs_options           = ["sync", "crossmnt", "no_root_squash"]
    volume_nfs_options    = ["sync", "crossmnt", "no_root_squash", "rw"]
  }
}
