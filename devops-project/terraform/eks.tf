# EKS Cluster - nodes in private subnets, control plane endpoint can be public/private
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Control plane endpoint (public for easier access; set to false for private-only)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Groups in private subnets
eks_managed_node_groups = {
  main = {
    name            = "${var.environment}-ng"
    instance_types  = var.node_group_instance_types

    min_size        = var.node_group_min_size
    max_size        = var.node_group_max_size
    desired_size    = var.node_group_desired_size

    subnet_ids = module.vpc.private_subnets

    version  = var.eks_cluster_version
    ami_type = "AL2_x86_64"

    tags = {
      Name = "${var.project_name}-${var.environment}-nodes"
    }
  }
}

tags = {
  Name = local.cluster_name
}

# Required for ALB Ingress Controller - OIDC and IAM
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
