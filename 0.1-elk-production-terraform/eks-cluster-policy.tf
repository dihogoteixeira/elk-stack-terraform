resource "aws_iam_policy" "policy-eks-cluster-control-plane" {
  name =  "policy-eks-cluster-control-plane"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeInstances",
        "ec2:CreateNatGateway",
        "ec2:CreateRoute",
        "ec2:CreateSecurityGroup",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeRouteTables",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeKeyPairs",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:TerminateInstances",
        "ec2:CreateTags",
        "ec2:DeleteRoute",
        "ec2:RunInstances",
        "ec2:DescribeNatGateways",
        "ec2:DescribeSecurityGroups",
        "ec2:DeleteNatGateway",
        "ec2:DescribeNetworkInterfaces"
        
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Sid": "eksAccess",
        "Effect": "Allow",
        "Action": [
            "eks:*",
            "ecr:*",
            "s3:*"
        ],
        "Resource": "*"
    },
    {
    "Sid": "LogsAccess",
    "Effect": "Allow",
    "Action": [
        "logs:DescribeLogGroups",
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup"
    ],
    "Resource": "*"
    },
    {
    "Effect": "Allow",
    "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetHostedZone",
        "route53:GetChange"
    ],
    "Resource": [
        "arn:aws:route53:::hostedzone/*",
        "arn:aws:route53:::change/*"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:AssociateVPCWithHostedZone"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "iam:PassRole"
        ],
        "Resource": [
            "arn:aws:iam::${var.aws-account-id}:role/role-eks-cluster-control-plane",
            "arn:aws:iam::${var.aws-account-id}:role/${var.cluster-name}*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "iam:CreateRole",
            "iam:CreateInstanceProfile",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:DeleteRole",
            "iam:DetachRolePolicy",
            "iam:AttachRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:PutRolePolicy",
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:DeleteInstanceProfile",
            "iam:UntagRole",
            "iam:TagRole"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:DescribeLoadBalancers"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DeleteScalingGroup",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DescribeAutoScalingInstances"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration"
        ],
        "Resource": [
            "arn:aws:autoscaling:us-east-1:${var.aws-account-id}:autoScalingGroup:*:autoScalingGroupName/${var.cluster-name}",
            "arn:aws:autoscaling:us-east-1:${var.aws-account-id}:launchConfiguration:*:launchConfigurationName/*}",
            "arn:aws:autoscaling:*:*:autoScalingGroupName/*}"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "EKSAccessServicePolicy-attach" {
   name = "EKSAccessServicePolicy"
   policy_arn = "${aws_iam_policy.policy-eks-cluster-control-plane.arn}"
   roles  = ["${aws_iam_role.role-eks-cluster-control-plane.name}"]
}
