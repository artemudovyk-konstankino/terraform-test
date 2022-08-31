variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "web_subnet" {
  description = "Web Subnet."
  type        = string
}

variable "main_vpc_name" {
  description = "Main VPC name."
  type        = string
}

variable "my_public_ip" {
  description = "Public IP address of the instance."
  type        = string
}

variable "ssh_public_key_path" {
  description = "SSH public key of the instance."
  type        = string
}

variable "web_port" {
  description = "Web port."
  type        = number
  default     = 80
}

variable "aws_region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile."
  type        = string
  default     = "personal"
}

variable "enable_dns" {
  description = "DNS support for the VPC."
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "Availability Zones in the Region."
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

variable "ami_list" {
  description = "List of AMIs to use."
  type        = map(string)
  default     = { "us-east-1" = "ami-05fa00d4c63e32376", "us-west-1" = "ami-018d291ca9ffc002f" }
}

variable "instance" {
  description = "EC2 instance to use."
  type = object({
    type                        = string
    cpu_core_count              = number
    associate_public_ip_address = bool
  })
  default = {
    type                        = "t2.micro"
    cpu_core_count              = 1
    associate_public_ip_address = true
  }
}
