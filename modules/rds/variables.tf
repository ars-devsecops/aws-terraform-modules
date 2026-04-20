variable "name"                    { type = string }
variable "vpc_id"                   { type = string }
variable "private_subnet_ids"       { type = list(string) }
variable "app_security_group_ids"   { type = list(string) }
variable "engine"                   { type = string; default = "mysql" }
variable "engine_version"           { type = string; default = "8.0" }
variable "instance_class"           { type = string; default = "db.t3.medium" }
variable "allocated_storage"        { type = number; default = 20 }
variable "db_name"                  { type = string }
variable "db_username"              { type = string }
variable "db_password"              { type = string; sensitive = true }
variable "db_port"                  { type = number; default = 3306 }
variable "multi_az"                 { type = bool; default = true }
variable "backup_retention_days"    { type = number; default = 7 }
variable "deletion_protection"      { type = bool; default = true }
variable "kms_key_arn"              { type = string; default = "" }
variable "cloudwatch_logs_exports"  { type = list(string); default = ["error", "slowquery"] }
variable "tags"                     { type = map(string); default = {} }
