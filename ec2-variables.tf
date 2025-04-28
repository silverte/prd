# Whether to create an workbench (True or False)
variable "create_ec2_instances" {
  description = "Whether to create an Workbench"
  type        = bool
  default     = false
}

# EC2 instance configurations
variable "ec2_instances" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    name              = string
    instance_number   = string # "01", "02", "03" 등
    availability_zone = string # "a" 또는 "c"
    ami_id            = string
    instance_type     = string
    private_ip        = string
    root_volume_size  = number
    data_volume_size  = number
    user_data_file    = string
  }))
  default = {}
}
