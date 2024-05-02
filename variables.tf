variable "aws_region" {
      description = "AWS region"
      type = string
      default = "eu-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t2.micro"
}

variable "ec2_instance_count" {
    description = "EC2 Instance Count"
    type = number
    default = 2
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 1
}