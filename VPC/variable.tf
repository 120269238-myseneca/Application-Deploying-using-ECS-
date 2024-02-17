variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "prefix" {
  default = "awscloud"
  type    = string
}



#Network 
#Project


variable "env" {
  default = "prod"
  type    = string
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "vpc" {
  default = "10.250.0.0/16"
  type    = string
}


variable "enable_dns_support" {
  default = true
  type    = bool

}

variable "enable_dns_hostnames" {
  default = true
  type    = bool

}

variable "public_cidr" {
  default = ["10.250.1.0/24", "10.250.2.0/24"]

  type = list(string)
}

variable "private_cidr" {
  default = ["10.250.4.0/24", "10.250.5.0/24"]
  type = list(string)
}



variable "create_nat_gateway" {
  default = "true"
  type    = bool
}