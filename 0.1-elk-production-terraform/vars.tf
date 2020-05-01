//----------------------- AWS Provider identity variables ---------------------------------//

# variable "aws_profile" {}
# variable "aws_role_arn" {}

variable "region" {
  default = "us-east-1"
}

variable "access_key" {}
variable "secret_key" {}

//----------------------- AWS Account ID-------------------------- -------------------------//
variable "aws-account-id" {}

//----------------------- AWS Availability Zones variables ---------------------------------//

variable "azs" {
  type = "list"
}

//----------------------- VPC Name --------------------------------------------------------//
variable "vpc-name" {}

variable "public-ips-ingress" {
  type = "list"
}

variable "private-subnets" {
  type = "list"
}

//----------------------- EKS Cluster Name ------------------------------------------------//

variable "cluster-name" {}

variable "instance-type" {}

variable "spot-price" {}

variable "key-name" {}

//----------------------- TAGs Information Deploy variables -------------------------------//

variable "Environment" {}
variable "project" {}
variable "EnvironmentType" {}

//-------------------------------------- AMI Instance Variable ----------------------------//

variable "ami" {}


//----------------------------------------------------------------------------------------//