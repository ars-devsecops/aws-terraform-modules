variable "name"                  { type = string }
variable "vpc_id"                 { type = string }
variable "ami_id"                 { type = string }
variable "instance_type"          { type = string; default = "t3.medium" }
variable "key_name"               { type = string; default = "" }
variable "private_subnet_ids"     { type = list(string) }
variable "alb_security_group_ids" { type = list(string); default = [] }
variable "target_group_arns"      { type = list(string); default = [] }
variable "app_port"               { type = number; default = 8080 }
variable "min_size"               { type = number; default = 2 }
variable "max_size"               { type = number; default = 6 }
variable "desired_capacity"       { type = number; default = 2 }
variable "root_volume_size"       { type = number; default = 20 }
variable "cpu_target_value"       { type = number; default = 60 }
variable "user_data"              { type = string; default = "" }
variable "tags"                   { type = map(string); default = {} }
