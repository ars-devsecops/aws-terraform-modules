variable "name"                      { type = string }
variable "vpc_id"                     { type = string }
variable "public_subnet_ids"          { type = list(string) }
variable "certificate_arn"            { type = string }
variable "app_port"                   { type = number; default = 8080 }
variable "target_type"                { type = string; default = "instance" }
variable "health_check_path"          { type = string; default = "/health" }
variable "internal"                   { type = bool; default = false }
variable "enable_deletion_protection" { type = bool; default = true }
variable "enable_test_listener"       { type = bool; default = true }
variable "access_logs_bucket"         { type = string; default = "" }
variable "tags"                       { type = map(string); default = {} }
