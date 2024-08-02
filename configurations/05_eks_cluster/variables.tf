variable "AppEnv" {
  description = "Application Environment"
  type        = string
}

variable "kms_key_id" {
  description = "The AWS KMS key identifier for encryption of the master user password"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "vpc_subnet_id" {
  description = "VPC Subnet ID"
  type        = list(string)
  default     = []
}

variable "cluster_access_role_arn" {
  description = "The ARN of the IAM role that provides permissions for the EKS cluster to make calls to AWS API operations on your behalf"
  type        = string
}

variable "create_vpc" {
  description = "Flag to create VPC"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = ""
}

variable "private_subnets_CIDR_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "public_subnets_CIDR_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}
