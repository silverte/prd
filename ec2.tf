################################################################################
# EC2 Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
################################################################################

module "ec2_instances" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = var.create_ec2_instances ? var.ec2_instances : {}

  create = true
  name   = "ec2-${var.service}-${var.environment}-${each.value.name}-${each.value.instance_number}-${each.value.availability_zone}"

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.availability_zone == "a" ? data.aws_subnets.app_vm_a.ids[0] : data.aws_subnets.app_vm_c.ids[0]
  vpc_security_group_ids      = try([module.security_group[each.value.name].security_group_id], null)
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  hibernation                 = false
  user_data                   = each.value.user_data_file != "" ? file("${path.module}/${each.value.user_data_file}") : null
  user_data_replace_on_change = true
  private_ip                  = each.value.private_ip
  iam_instance_profile        = each.value.name != "workbench" ? "role-${var.service}-${var.environment}-vm-app-default" : "role-${var.service}-${var.environment}-eks-admin"

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      volume_type = "gp3"
      volume_size = each.value.root_volume_size
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-${each.value.name}-${each.value.instance_number}-${each.value.availability_zone}-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = each.value.data_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-${each.value.name}-${each.value.instance_number}-${each.value.availability_zone}-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-${each.value.name}-${each.value.instance_number}-${each.value.availability_zone}"
    },
  )
}
