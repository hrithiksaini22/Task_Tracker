terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
/* you can also specify s3 as backend using s3 and dynamodb for state locking
backend "s3" {
    bucket         = "my-tf-test-bucket123321"  // bucket name
    key            = "prod/aws_infra" // path where terraform will save the file inside bucket
    region         = "us-west-1"
    dynamodb_table = "terraform-locks" // for locking the state file
    encrypt        = true
  } 
*/
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    // install tls provider for generating the SSH keys
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}
