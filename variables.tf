variable "cloudwatch_logs_group_name" {
  description = "Name of Cloudwatch Logs Group"
  type        = string
}

variable "instance_type" {
  description = "Instance type of node"
  default     = "m6a.xlarge"
  type        = string
}

variable "sso_user_ids" {
  description = "List of SSO user ids to allow access to Grafana"
  type        = list(string)
}
