resource "awscc_pcs_cluster" "pcs" {
  name = "pcs-cluster"
  tags = { project = var.project }

  networking = {
    subnet_ids         = [var.public_subnet_id]
    security_group_ids = [var.public_sg_id]
  }

  scheduler = {
    type    = "SLURM"
    version = var.slurm_version
  }

  size = "SMALL"

  slurm_configuration = {
    accounting = {
      mode                       = "STANDARD"
      default_purge_time_in_days = 7
    }

    slurm_rest = {
      mode = "STANDARD"
    }

    slurm_custom_settings = [
      { parameter_name = "MetricsType", parameter_value = "metrics/openmetrics" },
      { parameter_name = "CommunicationParameters", parameter_value = "enable_http" }
    ]
  }
}

locals {
  login_instance_template = (
    fileexists("${path.module}/templates/${var.instance_login}.userdata.tpl") ?
    "${path.module}/templates/${var.instance_login}.userdata.tpl" :
    "${path.module}/templates/default.userdata.tpl"
  )
}

resource "aws_launch_template" "pcs_login" {
  name_prefix = "pcs-login"
  tags        = { project = var.project }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  key_name = var.ssh_key

  iam_instance_profile {
    arn = var.pcs_compute_profile_arn
  }
  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    device_index                = 0
    network_card_index          = 0
    security_groups = [
      var.public_sg_id
    ]
  }

  user_data = base64encode(templatefile("${local.login_instance_template}", {
    zfs_dns    = var.zfs_filesystem_dns
    zfs_mnt    = var.zfs_filesystem_mnt
    lustre_dns = var.lustre_filesystem_dns
    lustre_mnt = var.lustre_filesystem_mnt
  }))

}

resource "awscc_pcs_compute_node_group" "login" {
  name       = "login"
  cluster_id = awscc_pcs_cluster.pcs.name
  tags = { project = var.project }
  custom_launch_template = {
    template_id = aws_launch_template.pcs_login.id
    version     = aws_launch_template.pcs_login.latest_version
  }
  iam_instance_profile_arn = var.pcs_compute_profile_arn
  ami_id                   = var.ami_id_x86
  instance_configs = [
    {
      instance_type = var.instance_login
    }
  ]
  scaling_configuration = {
    min_instance_count = 1,
    max_instance_count = 1
  }
  subnet_ids      = [var.public_subnet_id]
  purchase_option = "ONDEMAND"
}

resource "aws_placement_group" "pcs" {
  name     = "pcs"
  strategy = "cluster"
  tags     = { project = var.project }
}

locals {
  all_instances = toset(concat(var.instance_x86, var.instance_arm, var.instance_gpu))
  nics = { for instance in local.all_instances :
  instance => range(0, data.aws_ec2_instance_type.all[instance].maximum_network_cards) }
  cores = { for instance in local.all_instances :
  instance => data.aws_ec2_instance_type.all[instance].default_cores }
}

data "aws_ec2_instance_type" "all" {
  for_each      = local.all_instances
  instance_type = each.value
}

resource "aws_launch_template" "pcs" {
  for_each    = local.all_instances
  name_prefix = "pcs-${each.value}"
  tags        = { project = var.project }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  key_name = var.ssh_key
  # Turn off SMT for non-HPC instances (HPC instances don't support CpuOptions)
  dynamic "cpu_options" {
    for_each = startswith(each.value, "hpc") ? [] : [1]
    content {
      core_count       = local.cores[each.value]
      threads_per_core = 1
    }
  }

  iam_instance_profile {
    arn = var.pcs_compute_profile_arn
  }
  monitoring {
    enabled = true
  }
  placement {
    group_id = aws_placement_group.pcs.placement_group_id
  }
  dynamic "network_interfaces" {
    for_each = local.nics[each.value]
    iterator = nic
    content {
      associate_public_ip_address = false
      device_index                = tonumber(nic.value) >= 1 ? "1" : "0"
      network_card_index          = tonumber(nic.value)
      interface_type              = "efa"
      security_groups             = var.private_sg_ids
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/${each.value}.userdata.tpl", {
    zfs_dns    = var.zfs_filesystem_dns
    zfs_mnt    = var.zfs_filesystem_mnt
    lustre_dns = var.lustre_filesystem_dns
    lustre_mnt = var.lustre_filesystem_mnt
  }))
}

resource "awscc_pcs_compute_node_group" "x86" {
  for_each   = toset(var.instance_x86)
  name       = split(".", each.value)[0]
  cluster_id = awscc_pcs_cluster.pcs.name
  tags = { project = var.project }
  custom_launch_template = {
    template_id = aws_launch_template.pcs[each.value].id
    version     = aws_launch_template.pcs[each.value].latest_version
  }
  iam_instance_profile_arn = var.pcs_compute_profile_arn
  ami_id                   = var.ami_id_x86
  instance_configs = [
    {
      instance_type = each.value
    }
  ]
  scaling_configuration = {
    min_instance_count = 0,
    max_instance_count = 10
  }
  subnet_ids      = [var.private_subnet_id]
  purchase_option = "ONDEMAND"
}

resource "awscc_pcs_queue" "x86" {
  cluster_id = awscc_pcs_cluster.pcs.cluster_id
  name       = "x86"
  tags = { project = var.project }
  compute_node_group_configurations = [
    for ng in awscc_pcs_compute_node_group.x86 :
    { compute_node_group_id = ng.compute_node_group_id }
  ]

  slurm_configuration = {
    slurm_custom_settings = [
      {
        parameter_name  = "Default"
        parameter_value = "YES"
      }
    ]
  }

  depends_on = [awscc_pcs_cluster.pcs]
}

resource "awscc_pcs_compute_node_group" "arm" {
  for_each   = toset(var.instance_arm)
  name       = split(".", each.value)[0]
  cluster_id = awscc_pcs_cluster.pcs.name
  tags = { project = var.project }
  custom_launch_template = {
    template_id = aws_launch_template.pcs[each.value].id
    version     = aws_launch_template.pcs[each.value].latest_version
  }
  iam_instance_profile_arn = var.pcs_compute_profile_arn
  ami_id                   = var.ami_id_arm
  instance_configs = [
    {
      instance_type = each.value
    }
  ]
  scaling_configuration = {
    min_instance_count = 0,
    max_instance_count = 10
  }
  subnet_ids      = [var.private_subnet_id]
  purchase_option = "ONDEMAND"
}

resource "awscc_pcs_queue" "arm" {
  cluster_id = awscc_pcs_cluster.pcs.cluster_id
  name       = "arm"
  tags = { project = var.project }
  compute_node_group_configurations = [
    for ng in awscc_pcs_compute_node_group.arm :
    { compute_node_group_id = ng.compute_node_group_id }
  ]

  depends_on = [awscc_pcs_cluster.pcs]
}

data "aws_instances" "login" {
  filter {
    name   = "tag:aws:pcs:compute-node-group-id"
    values = [awscc_pcs_compute_node_group.login.compute_node_group_id]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
