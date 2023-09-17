terraform {
  backend "s3" {
    bucket         = "helm-aws"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "lockhelm"
    encrypt        = true
  }
}
