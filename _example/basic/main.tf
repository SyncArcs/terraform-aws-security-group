provider "aws" {
  region = "us-east-2"
}

locals {
  name        = "app"
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
  label_order = ["name"]
}


##-----------------------------------------------------------------------------
## Security Group Module Call.
##-----------------------------------------------------------------------------
module "security_group" {
  source      = "../../."
  name        = local.name
  environment = local.environment
  label_order = ["name"]
  vpc_id      = module.vpc.id

  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
    description = "Allow ssh traffic."
  },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow Mongodb traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
    description = "Allow ssh outbound traffic."
  },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow Mongodb outbound traffic."
    }
  ]
}