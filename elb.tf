################################################################################
# ELB Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-alb
################################################################################
module "alb_vm" {
  source = "terraform-aws-modules/alb/aws"
  create = var.create_alb_vm

  name                       = "alb-${var.service}-${var.environment}-vm"
  vpc_id                     = data.aws_vpc.vpc.id
  subnets                    = data.aws_subnets.elb.ids
  internal                   = true
  enable_deletion_protection = true

  # Security Group
  create_security_group = false
  security_groups       = var.alb_vm_security_groups

  tags = merge(
    local.tags,
    {
      "Name" = "alb-${var.service}-${var.environment}-vm"
    },
  )
}

module "nlb_vm" {
  source = "terraform-aws-modules/alb/aws"
  create = var.create_nlb_vm

  name               = "nlb-${var.service}-${var.environment}-vm"
  load_balancer_type = "network"
  vpc_id             = data.aws_vpc.vpc.id
  # subnets                          = data.aws_subnets.elb.ids
  internal                         = true
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = false
  subnet_mapping = [
    {
      subnet_id            = data.aws_subnets.elb_a.ids[0]
      private_ipv4_address = var.nlb_vm_ip_az_a
    },
    {
      subnet_id            = data.aws_subnets.elb_c.ids[0]
      private_ipv4_address = var.nlb_vm_ip_az_c
    },
  ]
  # Security Group
  create_security_group = false
  security_groups       = var.nlb_vm_security_groups

  tags = merge(
    local.tags,
    {
      "Name" = "nlb-${var.service}-${var.environment}-vm"
    },
  )
}

module "nlb_container" {
  source = "terraform-aws-modules/alb/aws"
  create = var.create_nlb_conatiner

  name               = "nlb-${var.service}-${var.environment}-container"
  load_balancer_type = "network"
  vpc_id             = data.aws_vpc.vpc.id
  # subnets                          = data.aws_subnets.elb.ids
  internal                         = true
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = false
  subnet_mapping = [
    {
      subnet_id            = data.aws_subnets.elb_a.ids[0]
      private_ipv4_address = var.nlb_container_ip_az_a
    },
    {
      subnet_id            = data.aws_subnets.elb_c.ids[0]
      private_ipv4_address = var.nlb_container_ip_az_c
    },
  ]

  create_security_group = false
  security_groups       = var.nlb_container_security_groups

  tags = merge(
    local.tags,
    {
      "Name" = "nlb-${var.service}-${var.environment}-container"
    },
  )
}
