include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
terraform {
    source = "github.com/SalmaAhmed20/terraform-aws-vpc/"
}
inputs ={
    VPC_NAME = "VPC_EKS"
}