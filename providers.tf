provider "awscc" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = {
      created = local.created_date
    }
  }
}

