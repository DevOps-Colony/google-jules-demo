# terraform/modules/vpc/variables.tf

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the VPC"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway"
  type        = bool
  default     = true
}
