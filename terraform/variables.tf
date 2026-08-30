variable "aws_region" {
  description = "AWS region in which to deploy the infrastructure."
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile. Use null to rely on the standard AWS credential chain."
  type        = string
  default     = null
  nullable    = true
}

variable "project_name" {
  description = "Prefix applied to resource names and tags."
  type        = string
  default     = "travel-memory"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private database subnet."
  type        = string
  default     = "10.20.2.0/24"
}

variable "admin_cidr" {
  description = "Administrator public IPv4 CIDR allowed to SSH to the web/bastion host, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid, restricted CIDR and cannot be 0.0.0.0/0."
  }
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the selected AWS region."
  type        = string
}

variable "private_key_path" {
  description = "Path used by Ansible/SSH to the private key matching key_name (for example ~/.ssh/travel-memory.pem)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for both assignment instances."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Encrypted gp3 root volume size in GiB."
  type        = number
  default     = 12
}
