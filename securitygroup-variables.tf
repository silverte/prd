# create_security_group
variable "create_security_groups" {
  description = "Whether to create security groups"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Map of security groups to create"
  type = map(object({
    resource_type = string
  }))
}
