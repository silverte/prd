##########################################################################
# IAM Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-iam
##########################################################################
module "iam_account" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-account"
  create_account_password_policy = var.create_account_password_policy

  account_alias = var.account_alias

  max_password_age             = 90
  minimum_password_length      = 8
  password_reuse_prevention    = 3
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_symbols              = true
  require_numbers              = true
}
