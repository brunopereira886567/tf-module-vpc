variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
}

variable "zones" {
  type    = any
  default = ["us-east-1a", "us-east-1b"]
}

variable "subnet_cidr_block_private" {
  type    = any
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_cidr_block_public" {
  type    = any
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

