module "eks_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"
  count   = var.create_vpc == true ? 1 : 0

  name            = "${local.application_name}-${var.AppEnv}-eks-vpc"
  azs             = var.availability_zones
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnets_CIDR_blocks
  public_subnets  = var.public_subnets_CIDR_blocks

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}
