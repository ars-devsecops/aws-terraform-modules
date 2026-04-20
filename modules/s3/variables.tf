variable "bucket_name"          { type = string }
variable "force_destroy"        { type = bool; default = false }
variable "enable_versioning"    { type = bool; default = true }
variable "enable_lifecycle"     { type = bool; default = true }
variable "object_expiry_days"   { type = number; default = 365 }
variable "kms_key_arn"          { type = string; default = "" }
variable "allowed_account_arns" { type = list(string); default = [] }
variable "logging_bucket"       { type = string; default = "" }
variable "tags"                 { type = map(string); default = {} }
