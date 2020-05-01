resource "aws_security_group" "sg-worker-node" {
  name = "${upper("sg-worker-node")}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  description = "Security group for all nodes in the cluster"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  tags = {
    Name = "${upper("sg-worker-node")}"
  }
}

resource "aws_security_group_rule" "worker-nodes-ingress" {
  description       = "Allow nodes to communicate with each other"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  source_security_group_id = "${aws_security_group.sg-worker-node.id}"
  security_group_id = "${aws_security_group.sg-worker-node.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "worker-nodes-ingress-control-plane" {
  description       = "Allow Worker Kubelets and pods receive communication from the cluster control plane"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.sg-cluster-control-plane.id}"
  security_group_id = "${aws_security_group.sg-worker-node.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https-worker" {
  description       = "Allow Pods to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.sg-cluster-control-plane.id}"
  security_group_id = "${aws_security_group.sg-worker-node.id}"
  type              = "ingress"
}

