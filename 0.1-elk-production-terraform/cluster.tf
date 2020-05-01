resource "aws_eks_cluster" "eks-cluster" {
  name = "${var.cluster-name}"
  role_arn = "${aws_iam_role.role-eks-cluster-control-plane.arn}"
  
    vpc_config {
      security_group_ids      = ["${aws_security_group.sg-cluster-control-plane.id}"]
  #   subnet_ids              = "${data.aws_subnet.private-subnets-ids.*.id}"
      subnet_ids              = "${var.private-subnets}"
      endpoint_private_access = true
      endpoint_public_access  = true
    }

  depends_on = [
    "aws_iam_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_policy_attachment.AmazonEKSServicePolicy",
    ]

    tags = "${
      map(
       "Name", "${upper(var.cluster-name)}",
       "Environment", "Monitoramento",
       "EnvironmentType", "PROD",
       "Project", "Monitoramento",
      )
    }"
  }

output "endpoint" {
  value = "${aws_eks_cluster.eks-cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.eks-cluster.certificate_authority.0.data}"
}
