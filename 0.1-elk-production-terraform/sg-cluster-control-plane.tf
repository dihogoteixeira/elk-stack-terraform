resource "aws_security_group" "sg-cluster-control-plane" {
  name = "${upper("sg-cluster-control-plane")}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  description = "Cluster communication with worker nodes"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${upper("sg-cluster-control-plane")}"
  }
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = "${var.public-ips-ingress}"
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg-cluster-control-plane.id}"
  to_port           = 443
  type              = "ingress"
}


resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description       = "Allow Pods to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.sg-worker-node.id}"
  security_group_id = "${aws_security_group.sg-cluster-control-plane.id}"
  type              = "ingress"
}


resource "aws_security_group_rule" "cluster-ingress-node-https-api" {
  description       = "Allow cluster control plane to communicate with pods running extension API Servers on port 443"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.sg-worker-node.id}"
  security_group_id = "${aws_security_group.sg-worker-node.id}"
  type              = "ingress"
}
