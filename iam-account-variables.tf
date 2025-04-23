# Whether to create account password policy (True or False)
variable "create_account_password_policy" {
  description = "Whether to create account password policy"
  type        = bool
  default     = false
}

# Account Alias
variable "account_alias" {
  description = "Account Alias"
  type        = string
  default     = ""
}
