####################### RETRIEVE AMI EKS INFORMATION ##############################

data "aws_ami" "worker-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks-cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["AWS_EKS_ACCOUNT"] # Amazon EKS AMI Account ID
}

###################### RETRIEVE NETWORK INFORMATION ###############################

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc-name}"
  }
}


# data "aws_acm_certificate" "certificate" {
#   domain   = "dteixeira.com.br"
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
# }
# 
# data "aws_route53_zone" "zone" {
#   name         = "dteixeira.com.br."
#   private_zone = false
# }

######################################################################################




# data "aws_subnet_ids" "private-subnets" {
#   vpc_id = "${data.aws_vpc.vpc.id}"
# 
#   tags = {
#     Name = "PVT-ZN-*"
#   }
# }
# 
# data "aws_subnet" "private-subnets-ids" {
#   count = "${length(data.aws_subnet_ids.private-subnets.ids)}"
#   id    = "${tolist(data.aws_subnet_ids.private-subnets.ids)[count.index]}"
# }

