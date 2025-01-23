variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "master_instance_type" {
  default = "t3.medium"
}

variable "data_instance_type" {
  default = "t3.large"
}

variable "kibana_instance_type" {
  default = "t3.medium"
}

variable "ami_id" {
  description = "AMI for Elasticsearch and Kibana nodes"
  default     = "ami-12345678" # Replace with actual AMI ID
}
