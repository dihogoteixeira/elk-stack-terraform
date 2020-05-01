// Create EKS Roles

resource "aws_iam_role" "role-eks-cluster-control-plane" {
  name = "role-eks-cluster-control-plane"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "AmazonEKSClusterPolicy" {
  name = "EKSClusterPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles = ["${aws_iam_role.role-eks-cluster-control-plane.name}"]
}

resource "aws_iam_policy_attachment" "AmazonEKSServicePolicy" {
  name = "EKSServicePolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  roles  = ["${aws_iam_role.role-eks-cluster-control-plane.name}"]
}
