################################################################################
# EFS Module
################################################################################

module "efs-app" {
  source = "terraform-aws-modules/efs/aws"
  create = var.create_efs_app

  # File system
  name            = "efs-${var.service}-${var.environment}-${var.efs_app_name}"
  creation_token  = "efs-${var.service}-${var.environment}-${var.efs_app_name}"
  encrypted       = true
  throughput_mode = "elastic"

  # File system policy
  attach_policy = false

  # Mount targets
  mount_targets = { for k, v in zipmap(local.azs, data.aws_subnets.app_pod.ids) : k => { subnet_id = v } }

  # security group
  create_security_group = false
  security_group_name   = "scg-${var.service}-${var.environment}-efs-${var.efs_app_name}"
  security_group_rules = {
    nfs_ingress = {
      description     = "Allow NFS traffic from app pod subnet"
      type            = "ingress"
      from_port       = 2049
      to_port         = 2049
      protocol        = "tcp"
      prefix_list_ids = ["pl-00f10ede9777e4752"] # Prefix list ID for pl-esp-stg-sub-app-pod-ip
    }
  }

  # Backup policy
  enable_backup_policy = false

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-efs-${var.efs_app_name}"
    }
  )
}
