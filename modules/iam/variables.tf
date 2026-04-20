variable "name"                  { type = string }
variable "trusted_account_arns"  { type = list(string); default = [] }
variable "artifact_bucket_name"  { type = string; default = "" }
variable "tags"                  { type = map(string); default = {} }
