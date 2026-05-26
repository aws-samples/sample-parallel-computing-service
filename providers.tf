provider "awscc" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = {
      project = var.project
      created = local.created_date
    }
  }
}

