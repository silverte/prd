# create_security_group rule
variable "create_security_group_rule_permanent" {
  description = "Whether to create a security group rule(permanent)"
  type        = bool
  default     = false
}

# create_security_group rule
variable "create_security_group_rule_temporary" {
  description = "Whether to create a security group rule(temporary)"
  type        = bool
  default     = false
}
