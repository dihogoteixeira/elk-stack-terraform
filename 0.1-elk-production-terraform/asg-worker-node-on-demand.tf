data "aws_region" "current" {}

## CONFIGURING BOOTSTRAPPING USERDATA

locals {
worker-node-on-demand = <<USERDATA
  #!/bin/bash
  set -o xtrace
  /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' '${var.cluster-name}'
  systemctl daemon-reload
  systemctl restart kubelet
USERDATA
}

## CREATING EKS WORKER NODE LAUNCH CONFIGURATION

resource "aws_launch_configuration" "lc-on-demand-worker-node" {
  name                        = "${upper("${var.cluster-name}-lc-on-demand-worker-node")}"
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
}

## CREATING EKS WORKER NODE AUTO SCALING GROUP

resource "aws_autoscaling_group" "asg-on-demand-worker-node" {
  name = "${upper("${var.cluster-name}-asg-on-demand-worker-node")}"
  min_size = 2
  max_size = 4
  launch_configuration = "${aws_launch_configuration.lc-on-demand-worker-node.id}"
  availability_zones = "${var.azs}"
  vpc_zone_identifier = "${var.private-subnets}"

  force_delete = true

    tags = [ 
      {
      key = "Name"
      value = "${upper("${var.cluster-name}-worker-node-on-demand")}"
      propagate_at_launch = true
      },
      {
      key                 = "kubernetes.io/cluster/${var.cluster-name}"
      value               = "owned"
      propagate_at_launch = true
      },
      {
      key                 = "Environment"
      value               = "${var.Environment}"
      propagate_at_launch = true
      },
      {
      key                 = "EnvironmentType"
      value               = "${var.EnvironmentType}"
      propagate_at_launch = true
      },
      {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
      }
    ]
}

