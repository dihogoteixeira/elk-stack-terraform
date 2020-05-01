locals {
  aws_auth = <<AWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.role-worker-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::${ACCOUNT_NUMBER}:user/eksadmin
      username: eksadmin
      groups:
        - system:masters
    - userarn: arn:aws:iam::${ACCOUNT_NUMBER}:user/dihogo.teixeira@gmail.com
      username: dihogo.teixeira@gmail.com
      groups:
        - system:masters
AWSAUTH
}

output "aws_auth" {
  value = "${local.aws_auth}"
}
