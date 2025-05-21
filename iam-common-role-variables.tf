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

# Whether to create an IAM vm role (True or False)
variable "create_iam_eks_admin_role" {
  description = "Whether to create an EKS admin role"
  type        = bool
  default     = false
}