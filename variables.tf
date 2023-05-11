variable "cloudwatch_logs_group_name" {
  description = "Name of Cloudwatch Logs Group"
  type        = string
}

variable "subnet_id" {
  description = "ID of subnet to deploy node"
  type        = string
}

variable "instance_type" {
  description = "Instance type of node"
  default     = "m6a.xlarge"
  type        = string
}
