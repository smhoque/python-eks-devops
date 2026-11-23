provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "python-eks-devops"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}


# --------------------------------------------------
# VPC
# --------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}


# --------------------------------------------------
# EKS
# --------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {

    main = {
      name = "python-api-nodes"

      instance_types = [var.instance_type]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type = "ON_DEMAND"

      disk_size = 20
    }
  }
}


# --------------------------------------------------
# ECR Repository
# --------------------------------------------------

resource "aws_ecr_repository" "python_api" {
  name                 = "python-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}