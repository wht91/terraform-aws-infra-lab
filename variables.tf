# variables.tf

variable "access_key" {
  description = "Access key to AWS console"
  default     = "xxxxx" # Add your access key
}

variable "secret_key" {
  description = "Secret key to AWS console"
  default     = "xxxxx" # Add your secret key
}

variable "rds_username" {
  description = "RDS instance master username"
  default     = "xxxxx" # Add your RDS username
}

variable "rds_password" {
  description = "RDS instance master password"
  default     = "xxxxx" # Add your RDS password
}
