# Whether to create an ALB ingress (True or False)
variable "create_alb_vm" {
  description = "Whether to create an ALB"
  type        = bool
  default     = false
}

# alb vm security groups
variable "alb_vm_security_groups" {
  description = "A list of security group IDs to associate with the ALB"
  type        = list(string)
  default     = []
}

# Whether to create an ALB ingress (True or False)
variable "create_nlb_vm" {
  description = "Whether to create an ALB"
  type        = bool
  default     = false
}

# nlb vm security groups
variable "nlb_vm_security_groups" {
  description = "A list of security group IDs to associate with the ALB"
  type        = list(string)
  default     = []
}

# nlb vm ip az a
variable "nlb_vm_ip_az_a" {
  description = "nlb vm ip az a"
  type        = string
  default     = "false"
}

# nlb vm ip az c
variable "nlb_vm_ip_az_c" {
  description = "nlb vm ip az c"
  type        = string
  default     = "false"
}

# Whether to create an ALB ingress (True or False)
variable "create_nlb_conatiner" {
  description = "Whether to create an ALB"
  type        = bool
  default     = false
}

# nlb container security groups
variable "nlb_container_security_groups" {
  description = "A list of security group IDs to associate with the ALB"
  type        = list(string)
  default     = []
}

# nlb container ip az a
variable "nlb_container_ip_az_a" {
  description = "nlb container ip az a"
  type        = string
  default     = "false"
}

# nlb container ip az c
variable "nlb_container_ip_az_c" {
  description = "nlb container ip az c"
  type        = string
  default     = "false"
}
