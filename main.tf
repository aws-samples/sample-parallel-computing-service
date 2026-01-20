module "vpc" {
  source = "./modules/vpc"

  region = var.region
  availability_zone = var.availability_zone
  vpc_cidr = var.vpc_cidr
  public_cidr = var.public_cidr
  private_cidr = var.private_cidr
}

module "iam" {
  source = "./modules/iam"
  ssh_key = var.ssh_key
}

module "s3" {
  source = "./modules/s3"
  s3_bucket = var.s3_bucket
}

module "fsx" {
  source = "./modules/fsx"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  public_subnet_id = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  public_cidr = var.public_cidr
  private_cidr = var.private_cidr
}

module "ldap" {
  source = "./modules/ldap"
  region = var.region
  ssh_key = module.iam.ssh_key
  private_subnet_id = module.vpc.private_subnet_id
  private_sg_id = module.vpc.private_sg_id
  s3_bucket = var.s3_bucket
  users_ldif = var.users
  depends_on = [
    module.s3.bucket
  ]
}

module "ami" {
  source = "./modules/ami"
  region = var.region
  ssh_key = module.iam.ssh_key
  public_subnet_id = module.vpc.public_subnet_id
  public_sg_id = module.vpc.public_sg_id
  slurm_version = var.slurm_version
  zfs_filesystem_dns = module.fsx.fs_openzfs_dns
  zfs_filesystem_mnt = "/fsx"
  ldap_dns = module.ldap.ldap_server_private_dns
  ldap_password = module.ldap.ldap_password
  s3_bucket = var.s3_bucket
  depends_on = [
    module.s3.bucket,
    module.ldap.ldap_server_private_dns
  ]
}

module "pcs" {
  source = "./modules/pcs"

  region = var.region
  ssh_key = module.iam.ssh_key
  ami_id_x86 = module.ami.x86_id
  slurm_version = var.slurm_version

  public_subnet_id = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id

  public_sg_id = module.vpc.public_sg_id
  private_sg_ids = [module.vpc.private_sg_id, module.fsx.fs_lustre_sg]

  pcs_compute_profile_arn = module.iam.pcs_compute_profile_arn

  instance_login = var.instance_login
  instance_gpu = var.instance_gpu
  capacity_block = var.capacity_block

  zfs_filesystem_dns = module.fsx.fs_openzfs_dns
  zfs_filesystem_mnt = "/fsx"

  lustre_filesystem_dns = module.fsx.fs_lustre_dns
  lustre_filesystem_mnt = module.fsx.fs_lustre_mnt
}

