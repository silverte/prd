# Whether to create an IAM assumeable role (True or False)
variable "create_iam_assumeable_role" {
  description = "Whether to create an IAM assumeable role"
  type        = bool
  default     = true
}

# Whether to create an IAM vm role (True or False)
variable "create_iam_vm_role" {
  description = "Whether to create an IAM vm role"
  type        = bool
  default     = false
}
