data "aws_iam_policy_document" "image_builder" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:*",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "imagebuilder:*",
      "s3:*",
      "logs:*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_imagebuilder_image_pipeline" "wx_x86" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.wx_x86.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.wx_x86.arn
  name                             = "wx_x86"
  status                           = "ENABLED"
  description                      = "Creates an Amazon Linux 2023 x86 image with PCS installed."

  schedule {
    schedule_expression = "cron(0 8 ? * tue)"
    pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  }
}

resource "aws_imagebuilder_image" "wx_x86" {
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.wx.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.wx_x86.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.wx_x86.arn

  depends_on = [
    data.aws_iam_policy_document.image_builder
  ]

  timeouts {
    create = "2h"
  }
}

data "aws_ami" "dlami_x86" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Deep Learning Base AMI with Single CUDA (Amazon Linux 2023) 20260109"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

resource "aws_imagebuilder_image_recipe" "wx_x86" {
    block_device_mapping {
      device_name = "/dev/xvda"
      no_device = false

      ebs {
        delete_on_termination = true
        volume_size           = 50
        volume_type           = "gp3"
      }
    }

    component {
      component_arn = aws_imagebuilder_component.wx.arn
      parameter {
        name = "BucketName"
        value = var.s3_bucket
      }
      parameter {
        name = "SlurmVersion"
        value = var.slurm_version
      }
      parameter {
        name = "ZFSDNS"
        value = var.zfs_filesystem_dns
      }
      parameter {
        name = "ZFSMnt"
        value = var.zfs_filesystem_mnt
      }
      parameter {
        name = "LDAPDNS"
        value = var.ldap_dns
      }
      parameter {
        name = "LDAPPassword"
        value = var.ldap_password
      }
    }

  name         = "amazon-linux-wx-x86"
  parent_image = data.aws_ami.dlami_x86.id
  version      = var.image_receipe_version
}

resource "aws_s3_object" "pcs_upload" {
  bucket = var.s3_bucket
  key    = "pcs-component.yaml"
  source = "${path.module}/pcs-component.yaml"
  etag = filemd5("${path.module}/pcs-component.yaml")
}

resource "aws_imagebuilder_component" "wx" {
  name       = "wx-pcs"
  platform   = "Linux"
  uri        = "s3://${var.s3_bucket}/pcs-component.yaml"
  version    = "1.0.0"

  depends_on = [
    aws_s3_object.pcs_upload
  ]
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "imagebuilder" {
  name_prefix        = "pcs-imagebuilder-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "imagebuilder" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
  role       = aws_iam_role.imagebuilder.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.imagebuilder.name
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "logs:*",

    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3" {
  name_prefix = "pcs-s3-access"
  description = "Allow all S3 access"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.imagebuilder.name
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name_prefix = "pcs-instance-profile-imagebuilder"
  role = aws_iam_role.imagebuilder.name
}

resource "aws_imagebuilder_infrastructure_configuration" "wx_x86" {
  description           = "PCS infrastructure configuration"
  instance_profile_name = aws_iam_instance_profile.iam_instance_profile.name
  instance_types        = [var.x86_build_instance]
  key_pair              = var.ssh_key
  name                  = "wx-pcs-x86"
  security_group_ids    = [var.public_sg_id]
  subnet_id             = var.public_subnet_id
  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = var.s3_bucket
      s3_key_prefix  = "image-builder"
    }
  }
}

resource "aws_imagebuilder_distribution_configuration" "wx" {
  name = "wx-pcs-local-distribution"

  distribution {
    ami_distribution_configuration {
     ami_tags = {
        Project = "WX PCS"
      }

      name = "wx-psc-{{ imagebuilder:buildDate }}"

      launch_permission {
        user_ids = ["905784713722"]
      }
    }
    region = var.region
  }
}

