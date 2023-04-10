#provides what cloud provider that going to use
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
#credential to connect to aws
provider "aws" {
  region                   = "ap-southeast-3"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}



