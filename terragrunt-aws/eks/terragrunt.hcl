include "root" {
  path = find_in_parent_folders()
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs_allowed_terraform_commands = ["validate","plan"]
  mock_outputs = {
    VPC_ID = "fake-vpc-id",
    VPC_CIDR ="10.1.0.0/16",
    PUB_SUBNET_ID="10.1.1.0/24"
    PRIV_SUBNET_ID1="10.1.2.0/24"
    PRIV_SUBNET_ID2="10.1.3.0/24"
  }
}
terraform {
    source = "github.com/SalmaAhmed20/terraform-aws-eks/"
}
inputs = {
    eks_name = "test"
    VPC_ID = dependency.vpc.outputs.VPC_ID
    VPC_CIDR = dependency.vpc.outputs.VPC_CIDR
    PRIV_SUBNET_ID1 = dependency.vpc.outputs.PRIV_SUBNET_ID1
    PRIV_SUBNET_ID2 = dependency.vpc.outputs.PRIV_SUBNET_ID2
    PUB_SUBNET_ID = dependency.vpc.outputs.PUB_SUBNET_ID
}