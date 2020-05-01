data "aws_region" "us-east-1" {}

## CONFIGURING BOOTSTRAPPING USERDATA

locals {
  worker-node-spot = <<USERDATA
  #!/bin/bash
  set -o xtrace
  /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' '${var.cluster-name}'
  systemctl daemon-reload
  systemctl restart kubelet
  USERDATA
}

## CREATING EKS SPOT WORKER NODE
resource "aws_spot_instance_request" "sg-worker-node-spot" {
  ami = "${var.ami}"
  instance_type = "${var.instance-type}"

  spot_price = "${var.spot-price}"
  wait_for_fulfillment = true
  spot_type = "one-time"

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      #!/bin/bash

      # Install additional requirements
      "sudo apt-get update && sudo apt-get install -y python-pip",
      "sudo pip install awscli",

      # Get spot instance request tags to tags.json file
      "AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 describe-spot-instance-requests --spot-instance-request-ids $4 --query 'SpotInstanceRequests[0].Tags' > tags.json",

      # Set instance tags from tags.json file
      " AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 create-tags --resources $5 --tags file://tags.json && rm -rf tags.json"
    ]
  }
}


## CREATING EKS WORKER NODE LAUNCH CONFIGURATION
resource "aws_launch_configuration" "lc-worker-node-spot" {
  name                        = "${upper("${var.cluster-name}-lc-worker-node-spot")}"
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.worker-nodes.name}"
  image_id                    = "${data.aws_ami.worker-node.id}"
  instance_type               = "${var.instance-type}"
  security_groups             = ["${aws_security_group.sg-worker-node.id}"]
  user_data_base64            = "${base64encode(local.worker-node-on-demand)}"
  key_name                    = "${var.key-name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      #!/bin/bash

      # Install additional requirements
      "sudo apt-get update && sudo apt-get install -y python-pip",
      "sudo pip install awscli",

      # Get spot instance request tags to tags.json file
      "AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 describe-spot-instance-requests --spot-instance-request-ids $4 --query 'SpotInstanceRequests[0].Tags' > tags.json",

      # Set instance tags from tags.json file
      " AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 create-tags --resources $5 --tags file://tags.json && rm -rf tags.json"
    ]
  }
}


## CREATING EKS WORKER NODE AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg-worker-node-spot" {
  name = "${upper("${var.cluster-name}-asg-worker-node-spot")}"
  min_size = 2
  max_size = 4
  launch_configuration = "${aws_launch_configuration.lc-worker-node-spot.id}"
  availability_zones = "${var.azs}"
  vpc_zone_identifier = "${var.private-subnets}"

  force_delete = true
  tags = [
    {
      key = "Name"
      value = "${upper("${var.cluster-name}-worker-node-spot")}"
      propagate_at_launch = true
    },
    {
      key = "kubernetes.io/cluster/${var.cluster-name}"
      value = "owned"
      propagate_at_launch = true
    },
    {
      key = "Environment"
      value = "${var.Environment}"
      propagate_at_launch = true
    },
    {
      key = "EnvironmentType"
      value = "${var.EnvironmentType}"
      propagate_at_launch = true
    },
    {
      key = "Project"
      value = "${var.project}"
      propagate_at_launch = true
    }
  ]

}