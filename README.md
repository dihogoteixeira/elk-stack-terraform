# CONFIGURAÇÃO AWS CLUSTER EKS

## Pré-requisitos:

- *Instalar o git*:
```
  https://git-scm.com/book/pt-br/v2/Come%C3%A7ando-Instalando-o-Git
```

- *aws cli*:
```
  https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-linux-al2017.html
```

- *Terraform `0.12` ou maior, nesse projeto foi utilizado a versão `0.12.13`. Para o gerenciamento das versões  utilizamos o gerenciador: `tfenv`*:
```
  https://github.com/tfutils/tfenv
```

- *kubectl*:
```
  https://docs.aws.amazon.com/pt_br/eks/latest/userguide/install-kubectl.html
```

- *aws-iam-authenticator*:
```
  https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
```  

- *Python versão > `2.9.3`*:
```
  https://realpython.com/installing-python/
```
--------------------------------------------------------------------

## Criar uma policy com as seguinte permissões para administração do cluster EKS:

```
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
                "*"
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
                "elasticloadbalancing:AddTags"
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
                "arn:aws:autoscaling:us-east-1:000000000000:autoScalingGroup:*:autoScalingGroupName/*",
                "arn:aws:autoscaling:us-east-1:000000000000:launchConfiguration:*:launchConfigurationName/*}",
                "arn:aws:autoscaling:*:*:autoScalingGroupName/*}"
            ]
        }
    ]
}
```
--------------------------------------------------------------------

## Criar um usuario (eksadmin) para administração do cluster eks e atachar a policy criada no passo anterior.

*Configurar o profile AWS para utilizar o usuario eksadmin, criado no passo anterior.*

Para confirmar o usuário que está configurado, utilize o comando:

```
  aws sts get-caller-identity

  {
    "UserId": "XXXXXXXXXXXXXXXXXXXXX",
    "Account": "000000000000",
    "Arn": "arn:aws:iam::000000000000:user/eksadmin"
}
```

Editar o arquivo terrafom.tfvars e informar as credenciais de acesso do usuário eksadmin:

```
  access_key = "XXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  region = "us-east-1"
```

Editar o arquivo aws_auth.tf e adicionar a ARN do usuário eksadmin, imprecindivelmente e a ARN dos demais usuários, conforme exemplo:

```
    mapUsers: |
    - userarn: arn:aws:iam::0000000000000:user/eksadmin
      username: eksadmin
      groups:
        - system:masters
    - userarn: arn:aws:iam::arn:aws:iam::0000000000000:user/username1
      username: username1
      groups:
        - system:masters
    - userarn: arn:aws:iam::0000000000000:user/username2
      username: username2 
      groups:
        - system:masters
```
--------------------------------------------------------------------

## AJUSTAR AS CONFIGURAÇÕES DE ACORDO COM O AMBIENTE E ORGANIZAÇÃO:


`1)` No arquivo `cluster.tf`, informar o nome da VPC criada anteriormente, conforme exemplo abaixo:
```
  data "aws_vpc" "vpc" {
    tags {
      Name = "<vpc_name>"
    }
  }
```
--------------------------------------------------------------------

## Caso esteja criando o cluster em uma VPC existente, é necessário adicionar as seguintes TAGs:


Para as subnets públicas, informar as `TAGs`:

```
  KEY                                         VALUE
  kubernetes.io/cluster/<nome-do-cluster>     shared 
  kubernetes.io/role/elb                      1
```

Para as subnet privadas, informar as `TAGs`:

```  
  KEY                                         VALUE
  kubernetes.io/cluster/<nome-do-cluster>     shared 
  kubernetes.io/role/internal-elb             1
```

`OBS:` Caso não exista é necessário criar uma VPC antes.

`2)` Configurar o Backend S3, para armazenar o arquivo de configuração do terraform, referente a criação do ambiente, conforme exemplo:  

```
     terraform {
       backend "s3" {
         bucket = "<bucket_name>"
         key    = "<directory_name>/remote-state/terraform.tfstate"
         region = "us-east-1"
       }
     }
```

`3)` Execute o comando: `terraform init`, para inicializar o diretório e validar as configurações:

```
  # terraform init
```

`4)` Execute o comando, terraform plan, para verificar se o plano de execução está de acordo com as configurações:

```
  # terraform plan 
```

`5)` Execute o comando `terraform apply`, para aplicar o plano de execução:

```
  # terraform apply
```
--------------------------------------------------------------------

## CONFIGURAR O ACESSO AO CLUSTER EKS VIA AWS-AUTENTHICATOR:


`6)` Execute os seguintes comandos para criar o arquivo de configuração `kubeconfig`, de acordo com o cluster eks:

```
  terraform output kubeconfig > /home/<user-name>/.kube/<cluster-name>-config
  KUBECONFIG=/home/<user-name>/.kube/<cluster-name>-config
  export KUBECONFIG=/home/<user-name>/.kube/<cluster-name>-config
```

`7)` Para testar se a configuração está funcionando, execute o comando:

```
  # kubectl get svc
```

O resultado retornado deverá ser conforme o exemplo abaixo:

```
  NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
  kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   62m
```
--------------------------------------------------------------------

## CONFIGURAR O ACESSO AOS NODES DO CLUSTER EKS


`8)` Para configurar o acesso aos worker nodes, edite o arquivo `aws_auth.tf` e infome os ARNs dos usuários que administrarão o cluster, confome exemplo abaixo:

```
  mapUsers: |
      - userarn: <arn:aws:iam::000000000000:user/username1>
        username: username1
        groups:
          - system:masters
```

`9)` Execute o comando abaixo para criar o arquivo `.yaml` com as configurações necessárias:

```
  # terraform output aws_auth > aws_auth.yaml
```

`10)` Para aplicar o arquivo de configuração gerado, execute o comando:

```
  # kubectl apply -f aws_auth.yaml
```

`11)` Para testar o acesso aos nodes do cluster `EKS`, execute o comando:

```
  # kubectl get nodes
```

O resultado retornado deverá ser, conforme o exemplo abaixo:

```
  NAME                         STATUS    ROLES     AGE       VERSION
  ip-10-0-0-67.ec2.internal    Ready     <none>    26s       v1.14.7-eks-1861c5
  ip-10-0-1-206.ec2.internal   Ready     <none>    30s       v1.14.7-eks-1861c5
```
--------------------------------------------------------------------
# Tasklists

- [x] Implementar Elasticsearch-master
- [x] Implementar Elasticsearch-client
- [x] Implementar Elasticsearch-data
- [x] Implementar Metricbeats
- [x] Implementar Filebeats
- [x] Implementar Functionbeats
- [x] Implementar Logstash
- [ ] Implementar APM
- [x] Implementar Index Life lifecycle management
- [x] Implementar Grafana
- [x] Implementar Prometheus
- [x] Implementar Work nodes on demand - Auto scaling group
- [x] Implementar Work nodes spot instances - Auto scaling group
- [x] Implementar Work nodes on demand - Lounch config
- [x] Implementar Work nodes spot instances - Lounch config
--------------------------------------------------------------------
## TROUBLESHOOTING



--------------------------------------------------------------------

