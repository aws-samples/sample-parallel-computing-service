provider "awscc" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

