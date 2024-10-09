provider "aws" {
  region = "us-east-2"
}

locals {
  name        = "app1"
  environment = "test"
}

##-----------------------------------------------------------------------------
## VPC Module Call.
##-----------------------------------------------------------------------------
module "vpc" {
  source      = "git::https://github.com/SyncArcs/terraform-aws-vpc.git?ref=v1.0.0"
  name        = "app"
  environment = "test"
  managedby   = "SyncArcs"
  cidr_block  = "10.0.0.0/16"
  label_order = ["name", "environment"]
}
##-----------------------------------------------------------------------------
## Security Group Rules Module Call.
##-----------------------------------------------------------------------------
module "security_group_rules" {
  source         = "../../."
  name           = local.name
  environment    = local.environment
  managedby      = "SyncArcs"
  vpc_id         = module.vpc.id
  new_sg         = false
  existing_sg_id = "sg-0efad39f681c9359d"

  ## INGRESS Rules
  existing_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.9.0.0/16"]
      description = "Allow Mongodb traffic."
    }
  ]

  ## EGRESS Rules
  existing_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.9.0.0/16"]
      description = "Allow Mongodb outbound traffic."
  }]

}
