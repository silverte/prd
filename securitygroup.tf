module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  for_each = var.create_security_group ? var.security_groups : {}

  create          = true
  name            = "scg-${var.service}-${var.environment}-${each.value.resource_type}-${each.key}"
  use_name_prefix = false
  description     = "Security group for ${each.value.resource_type} ${each.key}"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-${each.value.resource_type}-${each.key}"
    },
  )
}
