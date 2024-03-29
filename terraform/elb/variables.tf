variable "aws-region" {
  type = string
}

variable "aws-access-key-id" {
  type      = string
  sensitive = true
}

variable "aws-secret-access-key" {
  type      = string
  sensitive = true
}

variable "vpc-cidr-block" {
  type    = string
  default = "10.0.0.0/16"
}