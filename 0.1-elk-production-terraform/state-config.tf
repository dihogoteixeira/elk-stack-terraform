     terraform {
       backend "s3" {
         bucket = "elk-cluster"
         key    = "elk-stack-setup/remote-state/terraform.tfstate"
         region = "us-east-1"
       }
     }